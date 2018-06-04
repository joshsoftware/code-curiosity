module ContributionHelper
  def contribution_data(user = current_user)
    @user_commits = user.commits.group_by {|t| t.commit_date.beginning_of_month }
                                .sort
    @xAxis = []
    @commits = []
    @points = []
    @username = user.eql?(current_user) ? ['Your'] : ["#{user.name.titleize}'s"]
    @user_commits.map do |key, value|
      @xAxis << key.strftime('%b %Y')
      @commits << value.count
      @points << value.sum(&:auto_score)
    end
  end
end
