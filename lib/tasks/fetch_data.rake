namespace :fetch_data do
  desc "Fetch code-curiosity github repositories commits periodically."
  task :commits => :environment do |t|
    members = Member.all
    last_record = Commit.all.order("created_at DESC").last
    last_fetch_time = last_record ? last_record.created_at : Time.now - 3.month
    begin
      members.each do |member|
        team = member.team
        if team
          repos = team.repos
          repos.each do |repo|
            branches = GITHUB.repos.branches(user: 'joshsoftware', repo: repo.name).collect(&:name)
            
            branches.each do |branch|
              response = GITHUB.repos.commits.all('joshsoftware', repo.name, author: member.username, since: last_fetch_time, until: Time.now, sha: branch)
              
              unless response.body.blank?
                response.body.each do |data|
                  commit = data["commit"].to_hash
                  Commit.create(message: commit["message"], commit_date: commit["author"]["date"], 
                                member: member, team: team, repository: repo, html_url: data["html_url"])

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

  desc "Fetch new repository and store in database"
  task :repos => :environment do |t|
    repos  = Repository.fetch_remote_repos.as_json(only: [:name, :description, :watchers])
    repos.each do |repo|
      Repository.create(name: repo["name"], description: repo["description"], watchers: repo["watchers"]) if repo["name"] and !Repository.find_by(name: repo[:name])
    end
  end
  
  desc "Fetch comments,issues created by existing members"
  task activities: :environment do |t|
    last_fetch_time = MemberActivity.desc(:created_at).first || (Time.now - 1.month).beginning_of_day
    
    # currrenty tracking event
    TRACKING_EVENTS = {"IssueCommentEvent" => 'comment', "IssuesEvent" => 'issue'}
 
    Member.all.each do |member|
      activities  = GITHUB.activity.events.performed user: member.username, per_page: 100

      if member.team
        repos       = member.team.repos.pluck(:name).join("|")

        activities = activities.select{|a| Time.parse(a.created_at) > last_fetch_time && TRACKING_EVENTS.keys.include?(a.type) && a.repo.name.match(repos) }

        activities.each do |activity|
          type = TRACKING_EVENTS[activity.type] 

          member.member_activities.create!(
            description: activity.payload[type].body,
            event_type: type,
            repo: activity.repo,
            ref_url: activity.payload[type].html_url,
            team: member.team
          ) 
        end
      end
    end
  end
end
