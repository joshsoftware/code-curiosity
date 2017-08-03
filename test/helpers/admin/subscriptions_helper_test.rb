require "test_helper"

class Admin::SubscriptionsHelperTest < ActionView::TestCase

  test 'should return total subscription value' do
    create(:sponsorer_detail, sponsorer_type: "INDIVIDUAL",subscription_status: 'active')
    create(:sponsorer_detail, sponsorer_type: "INDIVIDUAL",subscription_status: 'canceled')
    create(:sponsorer_detail, sponsorer_type: "ORGANIZATION",subscription_status: 'active')
    assert_equal 255, total_subscription_amount
  end

end
