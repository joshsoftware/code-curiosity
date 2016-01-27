require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  test "repository name must be present" do
    repo = build(:repository,:name => nil)
    repo.valid?
    assert_not_empty repo.errors[:name]
  end

  test "repository source url must be present" do
    repo = build(:repository,:source_url => nil)
    repo.valid?
    assert_not_empty repo.errors[:source_url]
  end
  
  test "source url must be of valid format" do
    repo = build(:repository,:source_url => Faker::Internet.url)
    assert_no_match /\A(https|http):\/\/github.com\/[\.\w-]+\z/ , repo.source_url
  end
end
