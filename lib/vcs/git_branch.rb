module VCS
  class GitBranch
    attr_reader :git_username, :repo_name

    def initialize(git_username: , repo_name: )
      @git_username = git_username
      @repo_name = repo_name
    end

    def list
      GITHUB.repos.branches(user: git_username, repo: repo_name).list
    end
  end
end
