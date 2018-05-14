class Test
  include VCS

  attr_reader :user, :git_username, :repo_name,
              :branch_name, :from_date, :to_date

  def initialize(user: , repo_name: , branch_name: , **options)
    @user = user
    @repo_name = repo_name
    @branch_name = branch_name
    @git_username = options[:git_username].presence || user.github_handle
    @from_date = options[:from_date].presence || Date.yesterday.beginning_of_day
    @to_date = options[:to_date].presence || Date.yesterday.end_of_day
  end

  def fetch_and_store_commits
    commits_list = fetch_commits(repo_name, branch_name)

    commits_list.each do |commit|
      commit_record = user.commits.find_or_initialize_by( sha: commit['sha'] )

      commit_record.message = commit['commit']['message']
      commit_record.commit_date = commit['commit']['committer']['date']
      commit_record.html_url = commit['html_url']
      commit_record.comments_count = commit['commit']['comment_count']

      commit_record.save
    end
  end

  def fetch_commits(repo_name, branch_name)
    ::VCS::GitCommit.new(
      git_username: git_username,
      repo_name: repo_name,
      branch_name: branch_name
    ).list
  end
end
