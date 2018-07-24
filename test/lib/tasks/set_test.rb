require 'test_helper'

class SetTest < ActiveSupport::TestCase
  setup do
    CodeCuriosity::Application.load_tasks
  end

  test 'assign auto_score to score' do
    commit = create :commit, auto_score: 2

    assert_not_equal commit.score, commit.auto_score

    Rake::Task['set:score'].invoke
    commit.reload

    assert_equal commit.score, commit.auto_score
  end

  test 'set gh_repo_created_at and language for all repos' do
    VCR.use_cassette("set_created_at_and_language", match_requests_on: [:uri]) do
      repo = create(:repository, name: 'code-curiosity', owner: 'joshsoftware')
      auth_token = User.encrypter.encrypt_and_sign('your_access_token')
      create  :user, github_handle: 'tanya-saroha', created_at: Date.yesterday - 1, auth_token: auth_token

      GitApp.stubs(:info).returns(GITHUB)

      assert_nil repo.gh_repo_created_at
      assert_nil repo.language

      Rake::Task['set:repo_fields'].execute
      repo.reload

      assert_not_nil repo.gh_repo_created_at
      assert_not_nil repo.language
    end
  end

  describe 'catch exception in case invalid repo or github error' do
    test 'do not set gh_repo_created_at and language' do
      # invalid repo name and owner
      VCR.use_cassette("set_lang_invalid_repo", match_requests_on: [:uri]) do
        auth_token = User.encrypter.encrypt_and_sign('your_access_token')
        create  :user, github_handle: 'tanya-saroha', created_at: Date.yesterday - 1, auth_token: auth_token
        create(:repository, name: 'xyz1', owner: 'abc1')
        create(:repository, name: 'xyz2', owner: 'abc2')

        assert_equal Repository.where(gh_repo_created_at: nil, language: nil).count, 2

        Rake::Task['set:repo_fields'].execute

        assert_equal Repository.where(gh_repo_created_at: nil, language: nil).count, 2
      end
    end
  end
end
