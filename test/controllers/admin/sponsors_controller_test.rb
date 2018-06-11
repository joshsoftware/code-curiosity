require "test_helper"

class Admin::SponsorsControllerTest < ActionController::TestCase
  def setup
    role = create :role, :admin
    user  = create :user, auth_token: 'dah123rty'
    user.roles << role
    sign_in user
  end

  test 'show all sponsors' do
    create_list(:sponsor, 5)
    get :index
    assert_response :success
    assert_template 'index'
    assert_template partial: '_sponsors_table'
    assert_template partial: '_sponsors'
    assert_equal assigns(:sponsors).count, 5
  end

  test 'show all budgets of a sponsor' do
    sponsor_1 = create :sponsor
    create_list(:budget, 2, sponsor: sponsor_1)
    get :show, id: sponsor_1
    assert_response :success
    assert_template 'show'
    assert_equal sponsor_1.budgets.count, 2
  end

    test 'do not create sponsor and budget if invalid params' do
      params = {
        sponsor: {
          start_date: '',
          end_date: '',
          amount: ''
        }
      }
      get :create, params
      assert_equal Sponsor.count, 0
      assert_equal Budget.count, 0
    end

    test 'create sponsor and budget if valid params' do
      params = {
        sponsor: {
          name: 'abc',
          budgets_attributes: {
            '0': {
              start_date: Date.today,
              end_date: Date.today,
              amount: 100
            }
          }
        }
      }
      get :create, params
      assert_equal Sponsor.count, 1
      assert_equal Budget.count, 1
    end
end
