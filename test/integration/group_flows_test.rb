require "test_helper"

class GroupFlowsTest < ActionDispatch::IntegrationTest
  before(:all) do
    @round = create(:round, status: 'open')
    @user = create(:user, name: 'josh', auth_token: 'dah123rty', goal: create(:goal))
    Warden.test_mode!
  end

  after(:all) do
    Capybara.reset_sessions!
  end

  test "clicking on the new group shows the group form" do
    login_as @user
    visit groups_path
    #checking section-header content
    within 'section.content-header' do
      assert page.has_content?('Groups')
      assert page.has_link?('New Group')
      click_link('New Group')
    end
    #clicking on New Group shows new form
    within 'section.content' do
      #checking form
      page.assert_selector('form')
      #checking textboxes
      page.assert_selector('input', count: 1)
      page.assert_selector('textarea', count: 1)
      page.has_select?('input', name: 'name')
      page.has_select?('textarea', name: 'description')
      #checking create button
      page.has_button?('Create')
    end
  end

  test "should not submit form if group name or group description is empty" do
    login_as @user
    visit new_group_path
    #form validation
    within 'section.content' do
      click_button('Create')
      assert_empty find_field('group_name').value
      assert_empty find_field('group_description').value
      assert page.has_content? "can't be blank"
    end
  end

  test "should show created group and users after clicking on create button" do
    login_as @user
    visit new_group_path
    #filling form
    within 'section.content' do
      fill_in 'group_name', with: 'OpensourceContributor'
      fill_in 'group_description', with: 'participate in this'
      click_button('Create')
    end
    #after clicking on create button it should render show page with group name
    assert page.find('section.content-header').has_content?('Group: OpensourceContributor')
    #checking created group contents
    within 'section.content' do
      assert page.has_content?('Detail')
      assert page.has_content?('participate in this')
      assert page.has_content?('Users')
      assert page.has_content?('josh')
    end
  end

  test "only group owner can edit and add members to group" do
    login_as @user
    create_group
    visit group_path(@group)
    #edit_link and add members_link should be accessible to only group owner
    within 'section.content' do
      assert page.has_link?('Edit')
      assert page.has_link?('Add Members')
    end
  end

  test "clicking on the group name in the widget shows the group details" do
    login_as @user
    create_group
    visit group_widget_path(@group)
    within '.box' do
      assert page.has_link?('opensource')
      click_link('opensource')
    end
    #clicking on group name opens group in different window
    page.switch_to_window(page.windows.last)
    #page.save_and_open_screenshot
    #showing group details on clicking group
    assert page.find('section.content-header').has_content?('Group: opensource')
    within 'section.content' do
      assert page.has_content?('participate in this')
      assert page.has_content?('Users')
      assert page.has_content?('josh')
    end
  end

  test "clicking on the group name in the widget shows the group details even if the user is not logged in " do
    create_group
    visit group_widget_path(@group)
    within '.box' do
      click_link('opensource')
    end
    page.switch_to_window(page.windows.last)
    #page.save_and_open_screenshot
    assert page.find('section.content-header').has_content?('Group: opensource')
  end

  test "clicking on the user name in the widget shows the user profile" do
    login_as @user
    sub = create(:subscription, user: @user, :points => 1)
    @round.subscriptions << sub
    create_group
    visit group_widget_path(@group)
  
    page.switch_to_window(page.window_opened_by{
      page.find(:css, 'li', match: :first).click 
    })
    #page.save_and_open_screenshot
    assert page.find('section.content-header').has_content?('User Profile')
    assert page.find('section.content').has_content?('josh'.titleize)
  end

  test "clicking on the user name in the widget shows the user profile even if the user is not logged in" do
    sub = create(:subscription, user: @user, :points => 1)
    @round.subscriptions << sub
    create_group
    visit group_widget_path(@group)
  
    page.switch_to_window(page.window_opened_by{
      page.find(:css, 'li', match: :first).click 
    })
    #page.save_and_open_screenshot
    assert page.find('section.content-header').has_content?('User Profile')
  end

  test "group widget shows only last 3 months" do
    round2 = create(:round, from_date: 1.month.ago, end_date: 1.month.ago + 31.days)
    round3 = create(:round, from_date: 2.month.ago, end_date: 2.month.ago + 31.days)
    round4 = create(:round, from_date: 3.month.ago, end_date: 3.month.ago + 31.days)
    create_group
    visit group_widget_path(@group)
    within '.box' do
      assert page.has_link?(round2.from_date.strftime('%b %y'))
      assert page.has_link?(round3.from_date.strftime('%b %y'))
      assert page.has_link?(@round.from_date.strftime('%b %y'))
      assert page.has_no_link?(round4.from_date.strftime('%b %y'))
    end
  end

  def create_group
    @group = create(:group, name: 'opensource', description: 'participate in this')
    @group.owner = @user
    @user.groups << @group
  end
end
