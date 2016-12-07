class FileToBeIgnored
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :programming_language, type: String, default: "ruby"

  validates :name, presence: true

  def self.name_exist?(file_path)
    file_name = File.basename(file_path)
    where(name: /#{file_name}$/).any?
  end

end