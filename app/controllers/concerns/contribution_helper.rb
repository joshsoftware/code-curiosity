module ContributionHelper
  def contribution_data(user = current_user)
    @subscriptions = user.subscriptions.where(:created_at.gt => Date.parse("Feb 2016")).asc(:created_at)
    @xAxis = []
    @commits = []
    @activities = []
    @points = []
    @username = user.eql?(current_user) ? ['Your'] : ["#{user.name.titleize}'s"]
    @subscriptions.map{|s| @xAxis << s.round.name; @commits << s.commits_count; @activities << s.activities_count; @points << s.points}
  end
  
end
