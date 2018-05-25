require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  before(:all) do
    @round = create(:round, status: 'open')
    @user = create(:user, name: 'josh', auth_token: 'dah123rty', github_user_since: Date.today , goal: create(:goal))
    Warden.test_mode!
  end

  after(:all) do
    Capybara.reset_sessions!
  end

  # test "user can redeem only when redemption criterias will be met" do
  #   @user.github_user_since = Date.today - 6.months
  #   @user.created_at = Date.today - 3.months
  #   @user.save
  #   login_as @user
  #   visit user_path(@user)
  #   within 'section.content-header' do
  #     assert page.has_content?('User Profile')
  #   end
  #
  #   within 'section.content' do
  #     within '.box' do
  #       assert page.has_content?('Redeem Points')
  #       assert page.has_link?('Redeem Points')
  #       # click_link('Redeem Points')
  #       #page.save_and_open_screenshot
  #     end
  #   end
  #   #page.save_and_open_screenshot
  # end

  # test "user cannot redeem when redemption criterias will not be met" do
  #   login_as @user
  #   visit user_path(@user)
  #
  #   within 'section.content' do
  #     within '.box' do
  #       # assert page.has_content?('Redeem Points!')
  #       assert page.has_no_link?('Redeem Points')
  #       #page.save_and_open_screenshot
  #     end
  #   end
  # end
end
