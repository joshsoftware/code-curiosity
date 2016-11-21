class ScoringEngine
  attr_accessor :repo, :git, :repo_dir

  def initialize(repo)
    @repo = repo
    @repo_dir = Rails.root.join(config[:repositories], repo.id.to_s).to_s
  end

  def config
    SCORING_ENGINE_CONFIG
  end

  def fetch_repo(branch = nil)
    if Dir.exist?(repo_dir)
      # Default git pull will pull 'origin/master'. We need to handle the case
      # that repository has no master!
      # Rollbar#14
      self.git = Git.open(repo_dir)
      self.git.fetch
      #gets the current repository branch. usually, is master.
      branch = self.git.branches.local.first.name unless branch
      #checkout to the branch. if branch hasnt changed, checkout is redundant.
      self.git.checkout(branch)
      remote = self.git.config["branch.#{branch}.remote"] # usually just 'origin'
      begin
        self.git.pull(remote, branch)
      rescue Git::GitExecuteError
        #delete the repo dir and clone again
        FileUtils.rm_r("#{Rails.root.join(config[:repositories]).to_s}/#{repo.id}")
        self.git = Git.clone("https://github.com/#{repo.owner}/#{repo.name}.git", repo.id, path: Rails.root.join(config[:repositories]).to_s)
      end
    else
      self.git = Git.clone("https://github.com/#{repo.owner}/#{repo.name}.git", repo.id, path: Rails.root.join(config[:repositories]).to_s)
      #gets the current repository branch. usually, is master.
      branch = self.git.branches.local.first.name unless branch
      self.git.checkout(branch)
    end
    self.git
  end

  def comments_score(commit)
    return 0 if commit.comments_count == 0

    score = [
      commit.comments_count/config[:comments_to_points],
      config[:max_score]
    ].min

    return ([score, 1].max * config[:commit_comments_weightage])
  end

  def commit_score(commit)
    info = commit.info

    return 0 if info.nil? || info.stats.total == 0
    return 1 if info.stats.total > config[:code_change_threshold]

    score = [
      info.stats.total/config[:code_lines_to_points],
      config[:max_score]
    ].min

    return ([score, 1].max * config[:commit_default_weightage])
  end

  def bugspots_score(commit)
    return 0 if commit.info.nil?
    fetch_repo unless git
    # search all the origin branches that holds the commit and return the branch name.
    # git branch --all --contains <sha>
    # ex., git branch --all --contains fd891813e0f4a85e4b55a25d12f6d4d7de35c90b in prasadsurase/code-curiosity
    # "* delete-merge-conflict-repos\n  remotes/origin/delete-merge-conflict-repos"
    branches = git.commit_branches(commit.sha, {all: true, contains: true})
    branch = if branches.include?("\n")
               branches.split("\n").first.gsub('*', '').strip!
             else
               branches.gsub('*', '').strip!
             end

    # remotes/origin/skip-merge-branch-commit-scoring
    branch = git.branch(branch).name

    #get the latest commits for the branch
    git = fetch_repo(branch)

    bugspots = Bugspots.scan(repo_dir, branch).last

    #bugspot scoring of such files which are in the Ignored_list should be zero.
    bugspots_scores = bugspots.inject({}) do |r, s|
      if (FileToBeIgnored.name_exist?(s.file))
        s.score = "0.0000"
      end
      r[s.file] = s
      r
    end

    if bugspots_scores.any?
      max_score = bugspots_scores.max_by{|k,v| v.first.to_f}.last.score.to_f
    else
      max_score = 0
    end

    return 0 if max_score.to_i == 0

    total_changes = 0
    files_count = 0

    #Here files_count specifies how many files were changed excluding the ignored_files

    #Here total_changes specifies how many lines has been changed(added/deleted) per file, but should not
    # include changes of ignored_files for this commit

    total_score = commit.info.files.inject(0) do |result, file|

      file_score = bugspots_scores[file.filename]

      if FileToBeIgnored.name_exist?(file.filename)
        ignored_file = FileToBeIgnored.where(name: file.filename).first
        ignored_file.inc(count: 1)
      else
        total_changes += file.changes
        files_count += 1
      end

      if file_score
        result += (bugspots_scores[file.filename].score.to_f * config[:max_score])/max_score
      end

      result
    end

    #Here we are setting commit.info.stats.total as total changes of files excluding changes of ignored_files
    commit.info.stats.total = total_changes


    return 0 if total_score == 0

    score = [ total_score/files_count, config[:max_score] ].min

    return score * config[:bugspot_weightage]
  end

  def calculate_score(commit)
    score = bugspots_score(commit) + commit_score(commit) + comments_score(commit)
    return 1 if score == 0
    return [score.round, config[:max_score]].min
  end

end
