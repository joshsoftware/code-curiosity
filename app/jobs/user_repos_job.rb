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
    #check if the repository is not soft deleted and
    repo = Repository.unscoped.where(gh_id: gh_repo.id).first

    Sidekiq.logger.info "Repository name: #{gh_repo.name}, Repository owner: #{gh_repo.owner.login}, Stars: #{gh_repo.stargazers_count}, Forked: #{gh_repo.fork}"

    Sidekiq.logger.info "Repository already exists" if repo

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
      Sidekiq.logger.info "Repository does not include this user... Adding user" unless repo.users.include?(user)
      repo.users << user unless repo.users.include?(user)
      return
    end

    repo = Repository.build_from_gh_info(gh_repo)
    Sidekiq.logger.info "Repository INFO: Name: #{repo.name} | Stars: #{repo.stars} "

    if repo.stars >= REPOSITORY_CONFIG['popular']['stars']
      user.repositories << repo
      user.save
      Sidekiq.logger.info "Repository #{repo.name} persisted successfully for #{user.github_handle}"
      return
    end

    return unless gh_repo.fork
    return if repo.info.source.stargazers_count < REPOSITORY_CONFIG['popular']['stars']

    repo.popular_repository = repo.create_popular_repo
    repo.source_gh_id = repo.info.source.id
    user.repositories << repo
    user.save
    Sidekiq.logger.info "Persisted popular repository #{repo.name} for user #{user.github_handle}"
  end
end
