require "test_helper"

class FileToBeIgnoredTest < ActiveSupport::TestCase

  def setup
  super
  end

  test 'file name must be present' do
    file = build :file_to_be_ignored , name: nil
    file.valid?
    assert_not_empty file.errors[:name]
  end

  test 'file name is present in the ignore list' do
    file_1 = create :file_to_be_ignored, name: "Gemfile", programming_language: "ruby"
    file_2 = create :file_to_be_ignored, name: "Gemfile.lock", programming_language: "ruby"
    file_3 = create :file_to_be_ignored, name: "config/application.rb", programming_language: "ruby"
    file_4 = create :file_to_be_ignored, name: "app/models/application.rb", programming_language: "ruby"
    assert FileToBeIgnored.name_exist?("Gemfile")
    assert FileToBeIgnored.name_exist?("Gemfile.lock")
    assert FileToBeIgnored.name_exist?("application.rb")
  end

  test 'file name is absent in the ignore list' do
    file_1 = create :file_to_be_ignored, name: "Gemfile.lock", programming_language: "ruby"
    assert_not FileToBeIgnored.name_exist?("Gemfile")
    assert_not FileToBeIgnored.name_exist?("application.rb")
  end

  test 'file path is present in the ignore list' do
    file_1 = create :file_to_be_ignored, name: "config/application.rb", programming_language: "ruby"
    file_2 = create :file_to_be_ignored, name: "Gemfile.lock", programming_language: "ruby"
    assert FileToBeIgnored.name_exist?("config/application.rb")
  end

  test 'file path is absent in the ignore list' do
    file_1 = create :file_to_be_ignored, name: "Gemfile.lock", programming_language: "ruby"
    assert_not FileToBeIgnored.name_exist?("config/application.rb")
  end

  test 'folder path is present in the ignore list' do
  end

  test 'folder path is absent in the ignore list' do
  end
end
