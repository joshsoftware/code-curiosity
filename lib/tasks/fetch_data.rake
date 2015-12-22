namespace :fetch_data do
  desc "Fetch code-curiosity github repositories commits periodically."
  task :commits => :environment do |t|
    members = Member.all
    round = ENV['ROUND_ID'] ? Round.find(ENV['ROUND_ID']) : Round.find_by({status: 'open'})
    begin
      members.each do |member|
        team = member.teams.where(round: round).first
        if team
          repos = team.repos
          repos.each do |repo|
            user = repo.owner == member.username ? repo.owner : 'joshsoftware'
            branches = GITHUB.repos.branches(user: user, repo: repo.name).collect(&:name)
            
            branches.each do |branch|
              response = GITHUB.repos.commits.all(user, repo.name, author: member.username, since: round.from_date.beginning_of_day, until: ( round.end_date ? round.end_date.end_of_day : Time.now ), sha: branch)
              
              unless response.body.blank?
                response.body.each do |data|
                  commit = data["commit"].to_hash
                  Commit.create(message: commit["message"], commit_date: commit["author"]["date"], 
                                member: member, team: team, repository: repo, html_url: data["html_url"], round: round)

                end
              end
            end
          end
        end
      end
    rescue => e
      p "Error: #{e}"
    end
  end

  desc "Fetch new members and store in database"
  task :members => :environment do |t|
    pages =  [1,2]
    pages.each do |page|
      members  = GITHUB.orgs.teams.all_members(ORG_TEAM_ID, page: page).map(&:login)
      members.each do |member|
        Member.create(username: member) if member and !Member.find_by(username: member)
      end
    end
  end
  
  desc "Fetch comments,issues created by existing members"
  task activities: :environment do |t|
    round = Round.find_by({status: 'open'})
    
    # currrenty tracking event
    TRACKING_EVENTS = {"IssueCommentEvent" => 'comment', "IssuesEvent" => 'issue'}
 
    Member.all.each do |member|
      activities  = GITHUB.activity.events.performed user: member.username, per_page: 100

      team = member.teams.where(round: round).first
      if team
        repos       = team.repos.pluck(:name).join("|")

        activities = activities.select{|a| Time.parse(a.created_at) > round.from_date.beginning_of_day && TRACKING_EVENTS.keys.include?(a.type) && a.repo.name.match(repos) }

        activities.each do |activity|
          type = TRACKING_EVENTS[activity.type] 

          if member.username == activity.payload[type].user.login
            member.activities.create(
              description: activity.payload[type].body,
              event_type: type,
              repo: activity.repo,
              ref_url: activity.payload[type].html_url,
              team: team,
              commented_on: Time.parse(activity.created_at),
              round: round
            ) 
          end
        end
      end
    end
  end
end
