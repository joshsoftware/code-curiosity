class CommitsFetcher

  attr_accessor :repo, :user, :round

  def initialize(repo, user, round)
    @repo = repo
    @user = user
    @round = round
  end

  def fetch(type = :daily)
    user.gh_client.repos.branches(user: repo.owner, repo: repo.name).list.each do |branch|
      # Refer to issue https://rollbar.com/JoshSoftware/CodeCuriosity/items/8/
      # This is a quick fix where we ignore branches / repos that have moved.
      # This is related to https://github.com/piotrmurach/github/pull/258 and
      # we need to fix properly later.

      # Check if the name of hte branch exists. In case it's moved, it will send
      # ["message", "Moved Permanently"]:Array
      branch_commits(branch.name, type) if branch.try(:name)
    end
  end

  def branch_commits(branch, type)
    since_time = if type == :daily
                   Time.now - 30.hours
                 else
                   round.from_date.beginning_of_day
                 end

    response = user.gh_client.repos.commits.all( repo.owner, repo.name, {
      author: user.github_handle,
      since: since_time,
      'until': round.end_date ? round.end_date.end_of_day : Time.now,
      sha: branch,
      auto_pagination: true
    })

    return if response.body.blank?

    response.body.each do |data|
      create_commit(data)
    end
  end

  def create_commit(data)
    commit = repo.commits.find_or_initialize_by(sha: data['sha'])

    return if commit.persisted?

    commit.message = data['commit']['message']
    commit.commit_date = data['commit']['author']['date']
    commit.user = user
    commit.repository = repo
    commit.html_url = data['html_url']
    commit.comments_count = data['commit']['comment_count']
    commit.organization_id = repo.organization_id
    commit.round = round
    commit.save
  end

  def self.by_sha(repo, sha)
    user.gh_client.repos.commits.get(repo.owner, repo.name, sha)
  end

end
