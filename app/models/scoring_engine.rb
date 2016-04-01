class ScoringEngine
  class_attribute :config
  attr_accessor :repo, :git

  def initialize(repo, branch = 'master')
    @repo = repo
    @branch = branch
  end

  def fetch_repo
    repo_dir = File.join(ScoringEngine.config[:repositories], repo.id.to_s, repo.name)

    if Dir.exist?(repo_dir)
      self.git = Git.open(repo_dir).tap{|g| g.pull}
    else
      self.git = Git.clone(repo.ssh_url, repo.id, path: ScoringEngine.config[:repositories])
    end
  end

end
