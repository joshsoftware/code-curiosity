namespace :fetch_data do
  desc "Fetch code-curiosity github repositories commits periodically."
  task :commits, [:round, :user, :repo] => :environment do |t, args|
    round = args[:round] ? Round.find(args[:round]) : Round.find_by({status: 'open'})
    begin
      users = args[:user] ? [User.find(args[:user])] : User.contestants
      users.each do |user|
        repos = args[:repo] ? [Repository.find(args[:repo])] : user.repositories 
        repos.each do |repo|
          branches = GITHUB.repos.branches(user: repo.owner, repo: repo.name).collect(&:name)

          branches.each do |branch|
            response = GITHUB.repos.commits.all(
              repo.owner, 
              repo.name, 
              author: user.github_handle,
              since: round.from_date.beginning_of_day, 
              until: ( round.end_date ? round.end_date.end_of_day : Time.now ),
              sha: branch,
              per_page: 200
            )
            unless response.body.blank?
              response.body.each do |data|
                commit = data["commit"].to_hash
                Commit.create(
                  message: commit["message"], 
                  commit_date: commit["author"]["date"], 
                  user: user,
                  repository: repo, 
                  html_url: data["html_url"], 
                  round: round
                )
              end
            end
          end
        end
      end
    rescue => e
      p "Error: #{e}"
    end
  end

  desc "Fetch comments,issues created by existing members"
  task :activities, [:round, :user, :repo] => :environment do |t, args|
    round = args[:round] ? Round.find(args[:round]) : Round.find_by({status: 'open'})

    # currrenty tracking event
    TRACKING_EVENTS = {"IssueCommentEvent" => 'comment', "IssuesEvent" => 'issue'}

    users = args[:user] ? [User.find(args[:user])] : User.contestants
    users.each do |user|
      activities  = GITHUB.activity.events.performed(user: user.github_handle, per_page: 200)
      repos       = user.repositories.pluck(:name).join("|")

      activities = activities.select{|a| Time.parse(a.created_at) > round.from_date.beginning_of_day && TRACKING_EVENTS.keys.include?(a.type) && a.repo.name.match(repos) }

      activities.each do |activity|
        type = TRACKING_EVENTS[activity.type] 

        if user.github_handle == activity.payload[type].user.login
          user_activity = user.activities.find_or_initialize_by(event_type: 'IssueCommentEvent', gh_id: activity.id)

          user_activity.description = activity.payload[type].body
          user_activity.repo = activity.repo.name
          user_activity.ref_url = activity.payload[type].html_url
          user_activity.commented_on = Time.parse(activity.created_at)
          user_activity.round = round
          user_activity.user = user
          user_activity.repository = Repository.where(gh_id: activity.repo.id).first
          user_activity.save
        end
      end
    end
  end
end
