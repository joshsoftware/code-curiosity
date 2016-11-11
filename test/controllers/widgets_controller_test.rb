require "test_helper"

class WidgetsControllerTest < ActionController::TestCase

  let(:org) { 'joshsoftware' }
  let(:request_path) { "/orgs/#{org}" }
  let(:body) { File.read('test/fixtures/org.json') }
  let(:status) { 200 }

  def get_stub
    stub_get(request_path).to_return(body: body, status: status,
      headers: {content_type: "application/json; charset=utf-8"})
  end

  def setup
    super
    get_stub
    @goal = create :goal
    @round = create :round, :open
    @user = create :user, auth_token: 'dah123rty', goal: @goal
    @other_user = create :user, auth_token: 'dsadasda', goal: @goal
    @organization = create :organization
    @repo = create :repository_with_activity_and_commits, organization: @organization
    @group = create :group, owner: @user
    @group.members << @other_user
  end

  test 'show repository' do
    get :repo, id: @repo.id
    assert_response :success
    assert_template :repo
  end

  test 'show group widget' do
    get :group, id: @group.id
    assert_response :success
    assert_template :group
  end

  test 'should show error if commit auto_score is nil' do
    commit_1 = create(:commit, auto_score: nil, repository: @repo)
    @user.repositories << @repo
    @round.commits << commit_1
    assert_nothing_raised RuntimeError do
      @repo.leaders(@round)
    end
  end

  test 'should display scores correctly in repo widget' do
    commit_2 = create(:commit, auto_score: 1, repository: @repo)
    @user.repositories << @repo
    @round.commits << commit_2
    assert_nothing_raised RuntimeError do
      @repo.leaders(@round)
    end
  end

end
