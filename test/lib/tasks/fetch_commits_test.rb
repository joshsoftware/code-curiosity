require 'test_helper'

class FetchCommitsTest < ActiveSupport::TestCase
  setup do
    CodeCuriosity::Application.load_tasks
  end

  test 'daily commits' do
    VCR.use_cassette("my_commits", record: :new_episodes) do
      repo = create :repository, name: 'tanya-josh', owner: 'tanya-saroha', language: 'Ruby'
      auth_token = User.encrypter.encrypt_and_sign('your_access_token')
      create  :user, github_handle: 'tanya-saroha', created_at: Date.new(2018,07,01), auth_token: auth_token

      assert_equal repo.commits.count, 0
      Sidekiq::Testing.inline!

      Rake::Task[:fetch_commits].invoke

      Sidekiq::Testing.inline!
      repo.reload
      assert_equal repo.commits.count, 4

      assert_equal repo.commits[0].score, 0
      assert_nil repo.commits[0].reward
    end
  end
end
