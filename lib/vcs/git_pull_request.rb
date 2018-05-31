module VCS
  class GitPullRequest
    attr_reader :sha

    def initialize(sha)
      @sha  = sha
    end

    def get
      pull_requests = GitApp.info.search.issues("sha:#{sha}")
      return nil if pull_requests.items.size != 1
      pull_requests.items[0]
    end
  end
end
