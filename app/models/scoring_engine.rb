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
    begin
      branches = git.commit_branches(commit.sha, {all: true, contains: true})
      branch = if branches.include?("\n")
                 branches.split("\n").first.gsub('*', '').strip!
               else
                 branches.gsub('*', '').strip!
               end
    rescue Git::GitExecuteError
      branch = git.branches.local.first.name unless branch
    end


    # get the current git branch incase the commit is not found in any of the branches.

    # remotes/origin/skip-merge-branch-commit-scoring
    branch = get_current_git_branch(branch)

    #get the latest commits for the branch
    git = fetch_repo(branch)

    bugspots = Bugspots.scan(repo_dir, branch).last

    #bugspot scoring of such files which are in the Ignored_list should be zero.
    bugspots_scores = bugspots.inject({}) do |r, s|

      file = FileToBeIgnored.name_exist?(s.file)
      if file
        file.set(highest_score: s.score.to_f) if (s.score.to_f > file.highest_score)
        s.score = "0.0000" if file.ignored?
      end

      r[s.file] = s
      r
    end

    if bugspots_scores.any?
      max_score = bugspots_scores.max_by{|k,v| v.first.to_f}.last.score.to_f
    else
      max_score = 0
    end

    total_changes = 0
    files_count = 0

    #Here files_count specifies how many files were changed excluding the ignored_files

    #Here total_changes specifies how many lines has been changed(added/deleted) per file, but should not
    # include changes of ignored_files for this commit

    total_score = commit.info.files.inject(0) do |result, file|

      file_name = bugspots_scores[file.filename]
      file_exist = FileToBeIgnored.name_exist?(file.filename)

      if file_exist && file_exist.ignored?
        file_exist.inc(count: 1)
      else
        total_changes += file.changes
        files_count += 1
      end

      if file_name
        bugspot_score = file_name.score.to_f

        if file_exist && file_exist.programming_language.blank?
          file_exist.set(programming_language: repo.languages.first)
        elsif bugspot_score >= config[:bugspot_scores_threshold]
          FileToBeIgnored.create(name: file.filename, programming_language: repo.languages.first, highest_score: bugspot_score) unless file_exist
          file_exist.set(highest_score: bugspot_score) if (file_exist && bugspot_score > file_exist.highest_score)
        end

        result += (bugspot_score * config[:max_score])/max_score if max_score != 0
      end

      result
    end

    #Here we are setting commit.info.stats.total as total changes of files excluding changes of ignored_files
    commit.info.stats.total = total_changes


    return 0 if (total_score == 0 || files_count == 0)

    score = [ total_score/files_count, config[:max_score] ].min

    return score * config[:bugspot_weightage]
  end

  def calculate_score(commit)
    score = bugspots_score(commit) + commit_score(commit) + comments_score(commit)
    return 1 if score == 0
    return [score.round, config[:max_score]].min
  end

  # If there is error while getting current git branch retry 3 times and then delete the repo directory and clone again
  def get_current_git_branch(branch)
    tries ||= 3
    begin
      branch = git.branch(branch).name
    rescue
      retry unless (tries -= 1).zero?
      #delete repo directory and clone again
      FileUtils.rm_r("#{Rails.root.join(config[:repositories]).to_s}/#{repo.id}")
      self.git = Git.clone("https://github.com/#{repo.owner}/#{repo.name}.git", repo.id, path: Rails.root.join(config[:repositories]).to_s)
      branch = git.branch(branch).name
    end
  end

end
