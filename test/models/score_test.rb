require 'test_helper'

class ScoreTest < ActiveSupport::TestCase
  def test_user_must_be_present
    score = build :score, user: nil
    score.valid?
    assert_not_empty score.errors[:user]
    assert_includes(score.errors[:user], "can't be blank")
  end

  def test_value_must_be_present
    score = build :score, value: nil
    score.valid?
    assert_not_empty score.errors[:value]
    assert_includes(score.errors[:value], "can't be blank")
  end

  def test_value_must_be_integer
    score = build :score, value: 'abc'
    score.valid?
    assert_not_empty score.errors[:value]
    assert_includes(score.errors[:value], 'is not a number')
  end

  def test_value_must_be_greater_equal_to_zero
    score = build :score, value: -1
    score.valid?
    assert_not_empty score.errors[:value]
    assert_includes(score.errors[:value], 'must be greater than -1')
  end
end
