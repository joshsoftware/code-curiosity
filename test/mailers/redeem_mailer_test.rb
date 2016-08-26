require "test_helper"

class RedeemMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper 

  def test_mail_is_enqueued_to_be_delivered_later
    user = create(:user)
    transaction = create(:transaction, :type => 'credit', :points => 20, user: user)
    r = create(:redeem_request, :points => 2, user: user)
    assert_enqueued_jobs 1 do 
      RedeemMailer.redeem_request(r).deliver_later
    end 
  end

  def test_mail_should_be_delivered
    user = create(:user)
    transaction = create(:transaction, :type => 'credit', :points => 20, user: user)
    r = create(:redeem_request, :points => 2, user: user)
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      RedeemMailer.redeem_request(r).deliver_now
    end
  end

  def test_mail_is_delivered_with_expected_content 
    user = create(:user)
    transaction = create(:transaction, :type => 'credit', :points => 20, user: user)
    r = create(:redeem_request, :points => 2, user: user)
    perform_enqueued_jobs do 
      mail = RedeemMailer.redeem_request(r).deliver_now
      delivered_email = ActionMailer::Base.deliveries.last
      assert_includes delivered_email.to, mail.to.first 
    end
  end 

end
