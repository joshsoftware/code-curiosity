class FetchDataJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    members = Member.all
    last_record = Commit.all.order("created_at DESC").last
    last_fetch_time = last_record ? last_record.created_at : Time.now - 3.month
    members.each do |member|
      team = member.team
      if team
        repos = team.repos
        repos.each do |repo|
          response = GITHUB.repos.commits.all 'joshsoftware', repo.name, author: member.username, since: last_fetch_time, until: Time.now
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
end
