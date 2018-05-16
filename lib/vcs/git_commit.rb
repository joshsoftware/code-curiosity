module VCS
  class GitCommit
    attr_reader :repo_owner, :repo_name,
                :branch_name, :from_date, :to_date

    def initialize(**options)
      @repo_owner = options[:repo_owner]
      @repo_name = options[:repo_name]
      @branch_name = options[:branch_name]
      @from_date = options[:from_date]
      @to_date = options[:to_date]
    end

    def list
      GitApp.info.repos.commits.list(
        user: repo_owner,
        repo: repo_name,
        sha: branch_name,
        since: from_date,
        "until": to_date
      )
    end
  end
end
