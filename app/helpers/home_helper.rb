module HomeHelper
  #Fetch only the last 6 months data from today
  START_MONTH = 5
  START_OF_MONTH_FOR_HOME_PAGE_REPORT = START_MONTH.months.ago.beginning_of_month
  REPORT_DATE_FORMAT = "%B-%Y"
  def featured_groups
    @featured_groups =  Group.where(is_featured: true)
  end

  def featured_groups_size
    @size = @featured_groups.size
  end

  def widget_class
    if @size > 2
      "col-md-4"
    elsif @size == 2
      "col-md-6"
    else
      "col-md-12"
    end
  end

  #Need to create a rake and cron job which will extract the required data every month and store it in a collection. 
  #Those data can be directly fetched to render the report
  def multi_line_chart
    #Group data by month
    users = User.where(:created_at.gt => START_OF_MONTH_FOR_HOME_PAGE_REPORT, :created_at.lte => Date.today, auto_created: false).group_by{|u| u.created_at.strftime(REPORT_DATE_FORMAT)}

    contributions = Subscription.collection.aggregate( [ {"$match" => { "created_at" => { "$gt" => Date.parse("march 2016") } } }, { "$group" => { _id: "$round_id", total: { "$sum" => "$points" } } } ]).collect { |r| [ Round.find(r["_id"]).from_date.strftime("%b %Y"), r["total"] ] }.reverse

    @user_trend = []
    @contribution_trend = []
    @redemption_trend = []
    @xAxis = []
    
    sum = 0
    #cummulative sum
    users.map{ |user| @user_trend << sum += user[1].size}
    
    sum = 0
    contributions.map{ |contribution| @contribution_trend << contribution[1]; @xAxis << contribution[0]}
    
    sum = 0

 end

end
