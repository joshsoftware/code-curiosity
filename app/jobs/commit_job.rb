class CommitJob < ActiveJob::Base
  queue_as :git

  def perform(user_id=nil, repo_id=nil, round_id=nil)
    round = round_id ? Round.find(round_id) : Round.find_by({status: 'open'})
    begin
      users = user_id ? [User.find(user_id)] : User.contestants
      users.each do |user|
        repos = repo_id ? [Repository.find(repo_id)] : user.repositories 
        repos.each do |repo|
          branches = GITHUB.repos.branches(user: repo.owner, repo: repo.name, per_page: 1000).collect(&:name)

          branches.each do |branch|
            response = GITHUB.repos.commits.all(
              repo.owner, 
              repo.name, 
              author: user.github_handle,
              since: round.from_date.beginning_of_day, 
              until: ( round.end_date ? round.end_date.end_of_day : Time.now ),
              sha: branch
            )
            unless response.body.blank?
              response.body.each do |data|
                commit = data["commit"].to_hash
                Commit.create(
                  message: commit["message"], 
                  commit_date: commit["author"]["date"], 
                  user: user,
                  repository: repo, 
                  html_url: data["html_url"], 
                  round: round
                )
              end
            end
          end
        end
      end
    end
  end
end  
