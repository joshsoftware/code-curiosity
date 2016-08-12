require "test_helper"
require "database_cleaner"

class GoalTest < ActiveSupport::TestCase
  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    @goal = create(:goal)
  end

  test 'valid goal' do
    assert @goal.valid?
  end

  test 'invalid without name' do
    @goal.name = nil
    refute @goal.valid?, 'goal is valid without a name'
    assert_not_nil @goal.errors[:name], 'no validation error for name present'
  end

  test 'invalid without integer points' do
    @goal.points = 'abc'
    refute @goal.valid?, 'goal is valid without integer points'
    assert_not_nil @goal.errors[:points], 'no validation error for integer point'
  end

  test 'invalid if points less than 0' do
    @goal.points = -1
    refute @goal.valid?, 'goal is valid if points less than 0'
    assert_not_nil @goal.errors[:points], 'no validation error for points are greater than 0'
  end

  test '#info' do
    @goal.name = 'Hiker'
    assert_equal @goal.info, Goal.info['Hiker']
  end

  test '#self.info' do
    info = YAML.load_file(Rails.root.join('config', 'goals.yml'))['goals']
    assert_equal Goal.info, info
  end

  test '#self.setup' do
    assert_equal 3, Goal.setup.count
  end

  test '#self.default_goal' do
    @goal.name = 'Hiker'
    assert_equal Goal.default_goal, @goal
  end
end
