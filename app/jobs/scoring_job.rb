class ScoringJob < ActiveJob::Base
  queue_as :git

  def perform(user_id, repository_id = nil, round_id = nil)
    user = User.find(user_id)
    repositories = repository_id ? user.repositories.where(id: repository_id) : user.repositories
    round = round_id ? Round.find(round_id) : Round.find_by({status: 'open'})

    repositories.each do |repository|
      self.fetch_commits_and_activities(user, repository, round)
    end
  end

  def fetch_commits_and_activities(user, repository, round)
    CommitsFetcher.new(repository, user, round).fetch
    repository.score_commits(round)
    repository.set_files_commit_count

    ActivitiesFetcher.new(user, round).fetch
  end
end
