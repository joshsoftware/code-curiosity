class CommitsFetcher

  attr_accessor :repo, :user, :round

  def initialize(repo, user, round)
    @repo = repo
    @user = user
    @round = round
  end

  def fetch(type = :daily)
    GITHUB.repos.branches(user: repo.owner, repo: repo.name).each do |branch|
      branch_commits(branch.name, type)
    end
  end

  def branch_commits(branch, type)
    since_time = if type == :daily
                   Time.now - 30.hours
                 else
                   round.from_date.beginning_of_day
                 end

    response = GITHUB.repos.commits.all( repo.owner, repo.name, {
      author: user.github_handle,
      since: since_time,
      'until': round.end_date ? round.end_date.end_of_day : Time.now,
      sha: branch,
      per_page: 200
    })

    return if response.body.blank?

    response.body.each do |data|
      create_commit(data['commit'].to_hash, data['html_url'])
    end
  end

  def create_commit(data, html_url)
    commit = repo.commits.find_or_initialize_by(sha: data['tree']['sha'])

    return if commit.persisted?

    commit.message = data['message']
    commit.commit_date = data['author']['date']
    commit.user = user
    commit.repository = repo
    commit.html_url = html_url
    commit.comments_count = data['comment_count']
    commit.round = round
    commit.save
  end

  def self.by_sha(repo, sha)
    GITHUB.repos.commits.get(repo.owner, repo.name, sha)
  end

end
