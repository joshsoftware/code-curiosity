module HomeHelper

  def select_avatar(sponsorer)
    if sponsorer.avatar?
      sponsorer.avatar
    else
      avatar_url(sponsorer.user)
    end
  end

  def redirect(sponsorer)
    if sponsorer.organization_url?
      sponsorer.organization_url
    else
      user_path(sponsorer.user.github_handle.downcase)
    end
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

  def multi_line_chart

    users = User.collection.aggregate(
      [
        {
          "$match" => {"auto_created" => false }
        },
        {
          "$project" => {
            "month" => { "$month" => "$created_at"},
            "year" => {"$year" => "$created_at"}
          }
        },
        {
          "$group" => {
            _id: {"month" => "$month", "year" => "$year"},
            total: { "$sum" => 1 }
          }
        }
      ]
    ).sort_by do |r|
        [
          Date.parse(
            Date::ABBR_MONTHNAMES[r[:_id]["month"]] + " " + r[:_id]["year"].to_s
          )
        ]
      end
     .collect do |r|
       [
         Date::ABBR_MONTHNAMES[r[:_id]["month"]] + " " +r[:_id]["year"].to_s,
         r["total"]
       ]
     end

    contributions = Commit.collection.aggregate(
      [
        {
          "$match" => {
            "commit_date" => { "$gt" => Date.parse("01/04/2016") }
          }
        },
        {
          "$project" => {
            "month" => { "$month" => "$commit_date"},
            "year" => {"$year" => "$commit_date"},
            "auto_score" => 1
          }
        },
        {
          "$group" => {
            _id: {"month" => "$month", "year" => "$year"},
            total: { "$sum" => "$auto_score" }
          }
        }
      ]
    ).sort_by do |r|
        [
          Date.parse(
            Date::ABBR_MONTHNAMES[r[:_id]["month"]] + " " + r[:_id]["year"].to_s
          )
        ]
      end
     .collect do |r|
       [
         Date::ABBR_MONTHNAMES[r[:_id]["month"]] + " " +r[:_id]["year"].to_s,
         r["total"]
       ]
     end

    @user_trend = []
    @contribution_trend = []
    @user_xAxis = []
    @xAxis = []

    users.map{ |user| @user_trend << user[1]; @user_xAxis << user[0]}
    @user_trend = @user_trend.inject([]){ |acc, value| acc << acc.last.to_i + value.to_i }
    contributions.map{ |contribution| @contribution_trend << contribution[1]; @xAxis << contribution[0]}
 end

end
