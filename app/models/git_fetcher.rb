class GitFetcher
  include Vcs

  attr_reader :repo_owner, :repo_name,
              :branch_name, :from_date, :to_date

  def initialize(**options)
    @repo_owner = options[:repo_owner]
    @repo_name = options[:repo_name]
    @branch_name = options[:branch_name]
    @from_date = options[:from_date]
    @to_date = options[:to_date]
  end

  def fetch_and_store_commits
    commits_list = fetch_commits(repo_name, branch_name)
    commits_list.each do |commit|
      if commit['author']
        user = User.contestants.find_by(github_handle: commit['author']['login'])
        repo = Repository.find_by(name: repo_name, owner: repo_owner)

        if user && valid_commit?(user, commit['commit']['committer']['date'], commit['commit']['message'])
          commit_record = user.commits.find_or_initialize_by( sha: commit['sha'] )

          commit_record.repository = repo
          commit_record.message = commit['commit']['message']
          commit_record.commit_date = commit['commit']['committer']['date']
          commit_record.html_url = commit['html_url']
          commit_record.comments_count = commit['commit']['comment_count']

          stats = fetch_commit_stats(commit_record.sha, repo)
          commit_record.lines = stats.total

          commit_record.save
          asscoiate_with_pull_request(commit_record)

        end
      end
    end
  end

  private

  def fetch_commits(repo_name, branch_name)
    ::Vcs::GitCommit.new(
      repo_owner: repo_owner,
      repo_name: repo_name,
      branch_name: branch_name,
      from_date: from_date,
      to_date: to_date
    ).list
  end

  def fetch_commit_stats(sha, repo)
    ::Vcs::GitCommitStats.new(sha, repo).list
  end

  def asscoiate_with_pull_request(commit_record)
    pr_info = fetch_pull_request(commit_record.sha)
    if pr_info
      pr = PullRequest.find_or_initialize_by(number: pr_info.number)
      pr.label = pr_info.label
      pr.created_at_git = pr_info.created_at
      pr.comment_count = pr_info.comments
      pr.author_association = pr_info.author_association
      pr.commits << commit_record
      pr.save
    end
  end

  def fetch_pull_request(sha)
    ::Vcs::GitPullRequest.new(sha).get
  end

  def valid_commit?(user, date, message)
    !merge_pull_request_commit?(message) && committed_after_sign_up?(user, date)
  end

  def merge_pull_request_commit?(message)
    /merge pull request/i.match(message)
  end

  def committed_after_sign_up?(user, commit_date)
    user.created_at < commit_date
  end
end
