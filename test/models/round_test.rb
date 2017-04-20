require 'test_helper'

class RoundTest < ActiveSupport::TestCase

  def test_must_create_round
    assert_difference 'Round.count' do
      user = create(:round)
    end
  end

  def test_name_must_be_present
    round = build(:round,:name => nil)
    round.valid?
    assert_not_empty round.errors[:name]
  end


  def test_from_date_must_be_present
    round = build(:round,:from_date => nil)
    round.valid?
    assert_not_empty round.errors[:from_date]
  end

  def test_end_date_must_be_after_from_date
    round = build(:round)
    round.end_date = Time.now - 20.days
    round.valid?
    assert_not_empty round.errors[:end_date]
  end

  def test_default_status_should_be_inactive
    round = build(:round)
    round.valid?
    assert round.inactive?
  end

  def test_round_should_be_opened
    round = build(:round, :open)
    round.valid?
    assert round.open?
  end

  def test_round_should_be_closed
    round = build(:round, status: :close)
    round.valid?
    assert round.closed?
  end

  def test_only_one_round_should_be_open
    round_1 = create(:round, :open)
    assert round_1.persisted?
    assert round_1.valid?
    assert round_1.open?

    round_2 = build(:round, :open)
    assert round_2.open?
    assert round_1.valid?
    refute round_2.valid?
  end

  def test_next_round_must_be_created_after_closing_current_round
    round = build(:round, :status => 'open')
    assert_difference 'Round.count' do
      round.round_close
    end
  end

  def test_previous_round_should_be_closed_before_opening_next_round
    round = build(:round, :status => 'open')
    round.round_close
    assert_equal round.status, 'close'
  end

  def test_next_round_start_date_will_be_just_after_current_round_end_date
    round = build(:round, :status => 'open')
    round.round_close
    next_round_start_date = round.end_date + 1.second
    next_round = Round.first
    assert_equal next_round_start_date, next_round.from_date
  end

  def test_next_round_created_status_should_be_opened
    round = build(:round, :status => 'open')
    round.round_close
    next_round = Round.first
    assert next_round.open?
  end

end
