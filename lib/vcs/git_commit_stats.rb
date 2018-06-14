module VCS
  class GitCommitStats
    attr_reader :sha, :repo

    def initialize(sha, repo)
      @sha = sha
      @repo = repo
    end

    def list
      GitApp.info.repos.commits.get(
        user: repo.owner,
        repo: repo.name,
        sha: sha
      ).stats
    end
  end
end
