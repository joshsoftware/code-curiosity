desc 'hide the redeem requests which are undebited'
task :hide_undebited_requests => :environment do
  RedeemRequest.where(status: false).map(&:destroy)
  Transaction.where(hidden: true).map(&:destroy)
end