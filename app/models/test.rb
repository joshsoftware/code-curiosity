class Test
  include VCS

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
      user = User.contestants.find_by(email: commit['commit']['author']['email'])
      repo = Repository.find_by(name: repo_name, owner: repo_owner)

      if user && user.created_at < commit['commit']['committer']['date']
        commit_record = user.commits.find_or_initialize_by( sha: commit['sha'] )

        commit_record.repository = repo
        commit_record.message = commit['commit']['message']
        commit_record.commit_date = commit['commit']['committer']['date']
        commit_record.html_url = commit['html_url']
        commit_record.comments_count = commit['commit']['comment_count']

        commit_record.save
      end
    end
  end

  def fetch_commits(repo_name, branch_name)
    ::VCS::GitCommit.new(
      repo_owner: repo_owner,
      repo_name: repo_name,
      branch_name: branch_name,
      from_date: from_date,
      to_date: to_date
    ).list
  end
end
