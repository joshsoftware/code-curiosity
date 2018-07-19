require 'test_helper'
require 'sidekiq/testing'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

class FetchCommitsTest < ActiveSupport::TestCase
  def test_daily_commits
    VCR.use_cassette("my_commits") do
      repo = create :repository, name: 'tanya-josh', owner: 'tanya-saroha', language: 'Ruby'
      user = create  :user, github_handle: 'tanya-saroha', created_at: Date.yesterday - 1 
      assert_equal repo.commits.count, 0
      Sidekiq::Testing.inline!

      Rake::Task['fetch_commits'].invoke

      Sidekiq::Testing.inline!
      repo.reload
      assert_equal repo.commits.count, 3

      assert_equal repo.commits[0].score, 0
      assert_nil repo.commits[0].reward

      Rake::Task['score_and_reward'].invoke
      repo.commits[0].reload
      
      assert repo.commits[0].score > 5
      assert repo.commits[0].reward > 5
    end
  end
end
