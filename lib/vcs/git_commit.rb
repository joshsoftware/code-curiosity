module VCS
  class GitCommit
    attr_reader :git_username, :repo_name, :author_username,
                :branch_name, :from_date, :to_date

    def initialize(**options)
      @git_username = options[:git_username]
      @repo_name = options[:repo_name]
      @author_username = options[:author_username].presence || git_username
      @branch_name = options[:branch_name]
      @from_date = options[:from_date]
      @to_date = options[:to_date]
    end

    def list
      GITHUB.repos.commits.list(
        user: git_username,
        repo: repo_name,
        author: author_username,
        sha: branch_name,
        since: from_date,
        until: to_date
      )
    end
  end
end
