require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  def challenge
    @challenge ||= Challenge.new
  end

  describe 'new user is registered on code curiosity' do
    test 'should not have default challenge assigned' do
    end

    describe 'user wants to set a challenge' do
      test 'should display different challenge types with time period and reward' do
      end

      test 'should set desired challenge with level 1' do
      end
    end
  end

  describe 'user wants to deactivates challenge' do
    test 'should deactivates that challenge and should not carry forword previous points' do
    end
  end

  describe 'user deactivates his account' do
    test 'should deactivates all his challenges' do
    end
    
    describe 'user reactivates his account' do
      test 'should not have default challenge assigned(start again)' do
      end
    end
  end

  describe 'user wants to set new simultaneous challenge' do
    describe 'if new challenge type is same as active challenge types' do
      test 'should not create a challenge' do
      end
    end
    
    describe 'if new challenge type is different than active challenge types' do
      test 'should create a challenge' do
      end
    end
  end

  describe 'user wants to change duration of challenge' do
    test 'should not change time period(he can deactivate challenge)' do
      # do not provide option to change time period
    end
  end

  describe 'user with multiple challenge types, done commits on repository' do
    test 'should consider that repository in either of challenge(Not All)' do
    end
  end

  describe "At the end of challenge" do
    describe "if user did not set a default payment option" do
      test "should perform final scoring and send points to his wallet" do
      end
    end

    describe 'if user did set a payment option' do
      test "should perform final scoring and send amount to his account/credit card" do
      end
    end
  end

  describe 'user with challenge Y and Level X' do
    describe 'completes challenge successfully' do
      test 'should reward him max amount and he jumps to next level' do
      end
    end

    describe 'crosses threshold limit' do
      test 'should reward him threshold amount and stays at same level' do
      end
    end

    describe 'failed to cross threshold' do
      test 'should not reward any amount and falls down to previous level' do
      end
    end
  end

  describe 'user wants to get updates of his points between a challenge' do
    test 'should provide updates(manually or automatically)' do
    end
  end

  describe 'user wants to pause a challenge' do
    test 'should pause challenge until user resume it' do
    end

    test 'should not fetch commits and activities in pause duration' do
    end

    test 'should send notifications/mails' do
    end
  end
end

