require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test 'start date must be present' do
    budget = build(:budget, start_date: '')
    budget.valid?
    assert_not_empty budget.errors[:start_date]
  end

  test 'end date must be present' do
    budget = build(:budget, end_date: '')
    budget.valid?
    assert_not_empty budget.errors[:end_date]
  end

  test 'amount must be present' do
    budget = build(:budget, amount: '')
    budget.valid?
    assert_not_empty budget.errors[:amount]
  end

  describe 'after budget is created' do
    test 'set day amount' do
      budget = create :budget
      budget.valid?
      assert_not_nil budget.day_amount
    end
  end
end
