class ActivitiesFetcher
  TRACKING_EVENTS = {'IssueCommentEvent' => 'comment', 'IssuesEvent' => 'issue'}

  attr_accessor :user, :round

  def initialize(user, round)
    @user = user
    @round = round
  end

  def fetch(type = :daily)
    since_time = if type == :daily
                   Time.now - 30.hours
                 else
                   round.from_date.beginning_of_day
                 end

    repos = user.repositories.pluck(:gh_id)
    event_types = TRACKING_EVENTS.keys
    activities = GITHUB.activity.events.performed(user.github_handle, per_page: 200)

    activities.each do |a|
      if Time.parse(a.created_at) > since_time && event_types.include?(a.type) && repos.include?(a.repo.id)
        create_activity(a)
      end
    end
  end

  def create_activity(activity)
    type = TRACKING_EVENTS[activity.type]

    return unless user.github_handle == activity.payload[type].user.login

    user_activity = user.activities.find_or_initialize_by(gh_id: activity.id)
    user_activity.event_type = type
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
