class ScoringEngine
  attr_accessor :repo, :git, :repo_dir

  def initialize(repo)
    @repo = repo
    @repo_dir = File.join(config[:repositories], repo.id.to_s)
  end

  def config
    SCORING_ENGINE_CONFIG
  end

  def fetch_repo
    if Dir.exist?(repo_dir)
      self.git = Git.open(repo_dir) #.tap{|g| g.pull}
    else
      self.git = Git.clone(repo.ssh_url, repo.id, path: config[:repositories])
    end
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
    fetch_repo unless git

    branch = commit.branch.present? ? commit.branch : git.branch.name

    bugspots = Bugspots.scan(repo_dir, branch).last
    bugspots_scores = bugspots.inject({}){|r, s| r[s.file] = s; r}
    max_score = bugspots_scores.max_by{|k,v| v.first.to_f}.last.score.to_f

    return 0 if max_score == 0

    total_score = commit.info.files.inject(0) do |result, file|
      file_score = bugspots_scores[file.filename]

      if file_score
        result += (bugspots_scores[file.filename].score.to_f * config[:max_score])/max_score
      end

      result
    end

    score = [ total_score/commit.info.files.count, config[:max_score] ].min

    return score * config[:bugspot_weightage]
  end

  def calculate_score(commit)
     score = commit_score(commit) + comments_score(commit) + bugspots_score(commit)
     return [score.round, config[:max_score]].min
  end

end
