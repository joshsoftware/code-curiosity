class ActivitiesFetcher
  TRACKING_EVENTS = {'IssueCommentEvent' => 'comment', 'IssuesEvent' => 'issue'}

  attr_accessor :user, :round

  def initialize(user, round)
    @user = user
    @round = round
  end

  def self.fetch(round_id = nil)
    round = round_id ? Round.find(round_id) : Round.find_by({status: 'open'})

    User.contestants.all.each do |user|
      ActivitiesFetcher.new(user, round).fetch
    end
  end

  def fetch
    repos      = user.repositories.pluck(:name)
    event_types = TRACKING_EVENTS.keys
    activities = GITHUB.activity.events.performed(user: user.github_handle, per_page: 100)

    activities = activities.select do |a|
      Time.parse(a.created_at) > round.from_date.beginning_of_day && event_types.include?(a.type) && repos.include?(a.repo.name)
    end
  end

  def create_activity(activity)
    return unless user.github_handle == activity.payload[type].user.login

    type = TRACKING_EVENTS[activity.type]

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
