desc "Fetch commits daily."
task :fetch_commits, [:from_date, :to_date] => :environment do |t, args|
  from_date = args[:from_date].present? ? args[:from_date] : nil
  to_date = args[:to_date].present? ? args[:to_date] : nil
  repos = Repository.required

  repos.each do |repo|
    repo.branches.each do |branch|
      FetchCommitJob.perform_later(
                                   repo_owner: repo.owner,
                                   repo_name: repo.name,
                                   branch_name: branch,
                                   from_date: from_date,
                                   to_date: to_date
                                  )
    end
  end
end
