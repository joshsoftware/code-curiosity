module Vcs
  class GitRepository
    attr_reader :git_username

    def initialize(git_username: )
      @git_username = git_username
    end

    def list
      GITHUB.repos(user: git_username).list
    end
  end
end
