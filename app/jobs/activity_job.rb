class ActivityJob < ActiveJob::Base
  queue_as :git

  def perform(user_id=nil, round_id=nil)
    round = round_id ? Round.find(round_id) : Round.find_by({status: 'open'})

    # currrenty tracking event
    events = {"IssueCommentEvent" => 'comment', "IssuesEvent" => 'issue'}

    users = user_id ? [User.find(user_id)] : User.contestants
    users.each do |user|
      activities  = GITHUB.activity.events.performed user: user.github_handle, per_page: 100
      repos       = user.repositories.pluck(:name).join("|")

      activities = activities.select{|a| Time.parse(a.created_at) > round.from_date.beginning_of_day && events.keys.include?(a.type) && a.repo.name.match(repos) }

      activities.each do |activity|
        type = events[activity.type] 

        if user.github_handle == activity.payload[type].user.login
          user.activities.create(
            description: activity.payload[type].body,
            event_type: type,
            repo: activity.repo.name,
            ref_url: activity.payload[type].html_url,
            commented_on: Time.parse(activity.created_at),
            round: round,
            user: user
          ) 
        end
      end
    end
  end
end
