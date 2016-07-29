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
    contributions = Transaction.where(:created_at.gt => START_OF_MONTH_FOR_HOME_PAGE_REPORT, :created_at.lte => Date.today, :transaction_type.in => ['royalty_bonus', 'Round']).group_by{|u| u.created_at.strftime(REPORT_DATE_FORMAT)}
    redemptions = Transaction.where(:created_at.gt => START_OF_MONTH_FOR_HOME_PAGE_REPORT, :created_at.lte => Date.today, :transaction_type => 'redeem_points').group_by{|u| u.created_at.strftime(REPORT_DATE_FORMAT)}

    @user_trend = []
    @contribution_trend = []
    @redemption_trend = []
    @xAxis = []
    users.map{ |user| @user_trend << user[1].size}
    contributions.map{ |contribution| @contribution_trend << contribution[1].sum(&:points)}
    redemptions.map{ |redemption| @redemption_trend << (redemption[1].sum(&:points).abs/REDEEM['one_dollar_to_points'])}
    
    i = START_MONTH
    while(i >= 0) do
      @xAxis << i.months.ago.beginning_of_month.strftime(REPORT_DATE_FORMAT)
      i = i - 1
    end
=begin
    #Find the largest xAxis among the three 
    if users.keys.size > contributions.keys.size
      @xAxis = users.keys
      if redemptions.keys.size > users.keys.size 
        @xAxis = redemptions.keys
      end 
    else
      @xAxis = contributions.keys
      if redemptions.keys.size > users.keys.size
        @xAxis = redemptions.keys
      end
   end
=end
   index = 0
   #Fill in 0 for those don't have any value for that specific month, otherwise the report will show mismatched axis values.
   @xAxis.each{ |value|
     if !users.keys.include?(value)
       @user_trend.insert(index,0)
     end
     if contributions.keys.index(value).blank?
       @contribution_trend.insert(index,0)
     end
     if redemptions.keys.index(value).blank?
       @redemption_trend.insert(index,0)
     end
     index = index + 1
   }
 end

end
