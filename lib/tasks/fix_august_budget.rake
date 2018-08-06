desc 'fix budget for august 1 and 2'
task :fix_august_budget => :environment do
  budget = Budget.new
  budget.start_date = Date.new(2018, 8, 1)
  budget.end_date = Date.new(2018, 8, 2)
  budget.sponsor_id = Sponsor.first.id
  budget.amount = 20
  budget.is_all_repos = true

  Rake::Task[:score_and_reward].invoke('2018-8-01','2018-8-02')
end
