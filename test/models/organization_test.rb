require "test_helper"

class OrganizationTest < ActiveSupport::TestCase

  def setup
    stub_get("/orgs/joshsoftware").to_return(body: File.read('test/fixtures/org.json'), status: 200,
      headers: {content_type: "application/json; charset=utf-8"})
    create :round, :open
  end

  def stub_get(path, endpoint = Github.endpoint.to_s)
    stub_request(:get, endpoint + path)
  end

  def test_github_handle_must_be_present
    organization = build(:organization, :github_handle => nil)
    organization.valid?
    assert_not_empty organization.errors[:github_handle]
  end

  def test_repo_syncing_when_last_repo_sync_time_is_less_than_an_hour
    repo_sync_time = 45.minutes.ago
    organization = create(:organization, :last_repo_sync_at => repo_sync_time)
    assert organization.repo_syncing?
  end

  def test_repo_syncing_when_last_repo_sync_time_is_greater_than_an_hour
    repo_sync_time = 2.hours.ago
    organization = create(:organization, :last_repo_sync_at => repo_sync_time)
    assert_not organization.repo_syncing?
  end

  def test_organisation_informations_are_not_nil
    organization = build(:organization)
    assert_not_nil organization.info
  end

  def test_organization_setup
    admin = create(:user)
    assert_difference 'Organization.count' do
      Organization.setup('joshsoftware', admin)
    end
  end

  def test_created_organization_must_have_user
    admin = create(:user)
    org = Organization.setup('joshsoftware', admin)
    assert_not_nil org.users
  end

  def test_user_commits_and_update_all_commits_organization_belonging_to_a_repository
    organization = create(:organization_with_repositories)
    repository = create(:repository, name: "repo", source_url: Faker::Internet.url('github.com', "/#{Faker::Lorem.word}/#{Faker::Lorem.word}") , ssh_url: Faker::Internet.url('github.com', "/#{Faker::Lorem.word}/#{Faker::Lorem.word}"))
    commit = create(:commit, :message => Faker::Lorem.sentence)
    commit.repository = organization.repositories.first
    commit.save
    organization.link_user_activities
    commit.reload
    assert_not_nil commit.organization
  end

  def test_user_activities_and_update_all_activities_organization_belonging_to_a_repository
    organization = create(:organization_with_repositories)
    activity = create(:activity, :description => Faker::Lorem.sentence)
    activity.repository = organization.repositories.first
    activity.save
    organization.link_user_activities
    activity.reload
    assert_not_nil activity.organization
  end

end
