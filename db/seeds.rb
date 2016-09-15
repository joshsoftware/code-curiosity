# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Roles
Role.find_or_create_by(name: 'Admin')

if Rails.env.development?
  Goal.setup if Goal.count.zero?
  Round.create(name: 'first', from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month, status: :open) if Round.find_by(status: :open).nil?
end
