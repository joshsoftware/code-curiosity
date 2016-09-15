require "test_helper"
require "sidekiq/testing"

class HackathonsControllerTest < ActionController::TestCase
  setup do
    Sidekiq::Testing.fake!
    @user = FactoryGirl.create(:user, github_handle: "dummy")
    sign_in(@user)
  end

  teardown do
    sign_out(@user)
  end

  def create_hackathon
    #assert_difference 'Hackathon.count' do
      post :create, { name: "My Hack Day", 
             from: Date.today.beginning_of_day, 
             end: (Date.today + 2.days).end_of_day
      }, xhr: true
    #end
    assert_response :success
    assert_select ".repositories form"
    assert_select ".members form"
  end

  test "create a hackathon" do
    create_hackathon

    round = Round.where(name: "My Hack Day").first 
    group = Group.where(name: "My Hack Day").first

    assert_includes @user.round, round
    assert_equal group.owner, @user
  end

  test "create a hackathon with specific respositories" do
    create_hackathon

    assert_difference 'Hackathon.last.repositories.count', 2 do
      post repositories_hackathon_url(id: Hackathon.last), {
	       repositories: { "0": { name: 'dummy_repos_url' },
	                       "1": { name: "dummy_repos_2_url" }
               }
         }, xhr: true
    end
    assert_response :success
    assert_select "#repositories tr", 2 # there should be 2 repositories in the list
  end

  test "add member to hackathon if member registered with CodeCuriosity" do
    create_hackathon

    # create a dummy user!
    FactoryGirl.create(:user, github_handle: "dummy", email: "dummy@dummy.com")

    assert_difference 'Hackathon.last.group.members.count', 1 do
      post join_hackathon(id: Hackathon.last), {
	       "user_id": "dummy" 
         }, xhr: true
    end
    assert_response :success
    assert_select "#group-members tr", 2 # owner and new member
  end

  test "flash notice if github handle not registered with CodeCuriosity" do
    create_hackathon

    assert_no_difference 'Hackathon.last.group.members.count' do
      post join_hackathon(id: Hackathon.last), {
	       "user_id": "dummy" 
         }, xhr: true
    end
    assert_response :success
    assert_equal "No such user. Invite using email", flash[:notice]
  end

  test "invite member to hackathon if email not exist and is not registered with CodeCuriosity" do
    create_hackathon

    assert_no_difference 'Hackathon.last.group.members.count' do
      post join_hackathon(id: Hackathon.last), {
	       "user_id": "dummy@dummy.com" 
         }, xhr: true
    end
    assert_response :success
    # test if email was sent to dummy@dummy.com
  end

  test "show hackathon widget" do
  end
end
