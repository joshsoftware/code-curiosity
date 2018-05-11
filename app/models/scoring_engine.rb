class ScoringEngine
  attr_accessor :commit, :repo, :git, :repo_dir

  def initialize(commit:, repository:)
    @commit = commit
    @repo = repository
    @repo_dir = Rails.root.join(config[:repositories], repo[:_id].to_s).to_s
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
      Sidekiq.logger.info "#{self.git}"
      Sidekiq.logger.info "#{self.git.branch}"
      begin
        self.git.fetch
        #gets the current repository branch. usually, is master.
        branch = self.git.branches.local.first.name unless branch
        #checkout to the branch. if branch hasnt changed, checkout is redundant.
        self.git.checkout(branch)
        remote = self.git.config["branch.#{branch}.remote"] # usually just 'origin'
        self.git.pull(remote, branch)
      rescue Git::GitExecuteError
        #delete the repo dir and clone again
        FileUtils.rm_r("#{Rails.root.join(config[:repositories]).to_s}/#{repo[:_id]}")
        # self.git = Git.clone("https://github.com/#{repo.owner}/#{repo.name}.git", repo.id, path: Rails.root.join(config[:repositories]).to_s)
        self.git = clone_repo
      end
    else
      # self.git = Git.clone("https://github.com/#{repo.owner}/#{repo.name}.git", repo.id, path: Rails.root.join(config[:repositories]).to_s)
      self.git = clone_repo
      if self.git
        #gets the current repository branch. usually, is master.
        branch = self.git.branches.local.first.name unless branch
        self.git.checkout(branch)
      end
    end
    self.git
  end

  def comments_score
    Rails.logger.info "[#{commit[:_id]}] - Calculating comments_score started"
    if commit[:comments_count] == 0
      Rails.logger.info "[#{commit[:_id]}] - Calculating comments_score done. Response: #{0}"
      return 0
    end
    score = [
      commit[:comments_count]/config[:comments_to_points],
      config[:max_score]
    ].min

    score = ([score, 1].max * config[:commit_comments_weightage])
    Rails.logger.info "[#{commit[:_id]}] - Calculating comments_score done. Response: #{score}"
    score
  end

  def commit_score
    Rails.logger.info "[#{commit[:_id]}] - Calculating commit_score started"
    stats = commit[:info_json] && commit[:info_json][:stats]

    return 0 if stats.nil? || stats[:total] == 0
    return 1 if stats[:total] > config[:code_change_threshold]

    score = [
      stats[:total]/config[:code_lines_to_points],
      config[:max_score]
    ].min

    score = ([score, 1].max * config[:commit_default_weightage])
    Rails.logger.info "[#{commit[:_id]}] - Calculating commit score done. Response: #{score}"
    score
  end

  def bugspots_score
    Rails.logger.info "[#{commit[:_id]}] - Calculating bugspots score started"
    return 0 if commit[:info_json].blank?
    fetch_repo unless git
    return 0 unless git
    # search all the origin branches that holds the commit and return the branch name.
    # git branch --all --contains <sha>
    # ex., git branch --all --contains fd891813e0f4a85e4b55a25d12f6d4d7de35c90b in prasadsurase/code-curiosity
    # "* delete-merge-conflict-repos\n  remotes/origin/delete-merge-conflict-repos"
    begin
      branches = git.commit_branches(commit[:sha], {all: true, contains: true})
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
    begin
      # If Github doesn't returns commit info if commit has been moved.
      files = commit[:info_json][:files]
    rescue StandardError => e
      Sidekiq.logger.info "Absent commit: #{commit[:id]}, Error: #{e}"
      files = []
    end

    total_score = files.inject(0) do |result, file|

      file_name = bugspots_scores[file[:filename]]
      file_exist = FileToBeIgnored.name_exist?(file[:filename])

      if file_exist && file_exist.ignored?
        file_exist.inc(count: 1)
      else
        total_changes += file[:changes]
        files_count += 1
      end

      if file_name
        bugspot_score = file_name.score.to_f

        if file_exist && file_exist.programming_language.blank?
          file_exist.set(programming_language: repo[:languages].first)
        elsif bugspot_score >= config[:bugspot_scores_threshold]
          FileToBeIgnored.create(name: file[:filename], programming_language: repo[:languages].first, highest_score: bugspot_score) unless file_exist
          file_exist.set(highest_score: bugspot_score) if (file_exist && bugspot_score > file_exist.highest_score)
        end

        result += (bugspot_score * config[:max_score])/max_score if max_score != 0
      end
      result
    end

    #Here we are setting commit.info.stats.total as total changes of files excluding changes of ignored_files
    commit[:info_json][:stats][:total] = total_changes


    return 0 if (total_score == 0 || files_count == 0)

    score = [ total_score/files_count, config[:max_score] ].min

    score = score * config[:bugspot_weightage]
    Rails.logger.info "[#{commit[:_id]}] - Calculating bugspots score completed. Response: #{score}"
    score
  end

  def calculate_score
    Rails.logger.info "[#{commit[:_id]}] - Score calculation started"
    score = bugspots_score + commit_score + comments_score
    Rails.logger.info "[#{commit[:_id]}] - Score calculation done, Response: #{score}"
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
      FileUtils.rm_r("#{Rails.root.join(config[:repositories]).to_s}/#{repo[:_id]}")
      self.git = Git.clone("https://github.com/#{repo[:owner]}/#{repo[:name]}.git", repo[:_id], path: Rails.root.join(config[:repositories]).to_s)
      branch = git.branch(branch).name
    end
  end

  private
  # method to clone repository if repository failed to clone it will retry for ten times
  # if it fails in all retries the method will return nil
  # sometimes git clone fails stating
  # No such file or directory
  # fatal: cannot store pack file
  # fatal: index-pack failed
  def clone_repo
    begin
      retries ||= 0
      Git.clone("https://github.com/#{repo[:owner]}/#{repo[:name]}.git", repo[:_id], path: Rails.root.join(config[:repositories]).to_s)
    rescue Git::GitExecuteError
      retry if (retries += 1) < 10
      FileUtils.rm_r("#{Rails.root.join(config[:repositories]).to_s}/#{repo[:_id]}") if Dir.exist?(repo_dir)
      Sidekiq.logger.info "Unable to clone repositoriy: #{repo[:_id]}"
      return nil
    end
  end

end
