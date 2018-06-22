class UserReposJob < ActiveJob::Base
  include Sidekiq::Status::Worker
  queue_as :git

  attr_accessor :user

  rescue_from(StandardError) do |exception|
    Sidekiq.logger.info "**************************************Exception *******************************"
    Sidekiq.logger.info "User: #{user.github_handle}"
    Sidekiq.logger.info "Exception: #{exception.inspect}"
    user.set(last_repo_sync_at: nil) if user
  end

  def perform(user_id)
    user = User.find(user_id)

    return if user.repo_syncing?
    user.set(last_repo_sync_at: Time.now)
    @user = user

    Sidekiq.logger.info "************************* UserReposJob Logger Info ***************************"
    Sidekiq.logger.info "Syncing repositories of #{user.github_handle}"
    Sidekiq.logger.info "Last repository sync at: #{user.last_repo_sync_at}"

    gh_repos = user.fetch_all_github_repos

    gh_repos.each do |gh_repo|
      add_repo(gh_repo)
    end
  end

  def add_repo(gh_repo)
    repo = Repository.new(name: gh_repo.name, owner: gh_repo.owner.login)
    info = gh_repo.fork ? repo.info.source : gh_repo

    #check if the repository is not soft deleted and
    repo = Repository.unscoped.where(gh_id: info.id).first

    Sidekiq.logger.info "Repository name: #{info.name}, Repository owner: #{info.owner.login}, Stars: #{info.stargazers_count}, Forked: #{info.fork}"

    if repo
      # Commenting the fuctionality since rails 4.2 has an issue with accessing soft deleted parent association. Refer rails issue#10643.
=begin
      if repo.info.stargazers_count < REPOSITORY_CONFIG['popular']['stars']
        repo.set(stars: gh_repo.stargazers_count)
        # soft delete the repo if it isnt a fork and the star rating has declined.
        repo.destroy if repo.source_gh_id.nil?
      else
        # restore the repo if the repository was already soft deleted and the current star count is greater then the threshold
        if repo.destroyed?
          repo.restore
          # recreate the relationship between repository and its associated users.
          repo.users.each{|u| u.repositories << repo }
        end
        repo.set(stars: repo.info.stargazers_count)
      end
=end
      Sidekiq.logger.info "Repository already exists"
      Sidekiq.logger.info "Repository does not include this user... Adding user" unless repo.users.include?(user)
      repo.users << user unless repo.users.include?(user)
      repo.set(gh_repo_updated_at: gh_repo.updated_at)
      return
    end

    return if info.stargazers_count < REPOSITORY_CONFIG['popular']['stars']

    user_repo = Repository.build_from_gh_info(info)
    user_repo.save
    user.repositories << user_repo
    user.save
    Sidekiq.logger.info "Persisted repository #{repo.name} for user #{user.github_handle}"
  end
end
