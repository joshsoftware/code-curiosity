require "test_helper"

class SubscriptionSerializerTest < ActiveSupport::TestCase
  def setup
    super
    create :round, :open
    user = create(:user)
    @subscription = create(:subscription, user: user, round: Round.opened)
    create(:commit, user: user)
    create(:activity, user: user)
    @subscription.update_points
  end

  test 'serialize the subscription' do
    serializer = SubscriptionSerializer.new(@subscription)
    data = serializer.serializable_hash

    assert_equal @subscription.id, data[:id]
    assert_equal @subscription.points, data[:points]
    assert_equal @subscription.commits_count, data[:commits_count]
    assert_equal @subscription.activities_count, data[:activities_count]
    assert_equal @subscription.round.from_date.strftime("%b %Y"), data[:round_date]
  end

end
