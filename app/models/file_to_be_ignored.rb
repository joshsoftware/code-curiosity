class FileToBeIgnored
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :programming_language, type: String, default: "ruby"
  field :ignored, type: Boolean, default: false
  field :count, type: Integer, default: 0

  validates :name, :programming_language, presence: true

  def self.name_exist?(file_path)
    file_name = File.basename(file_path)

    return false if file_name.blank?

    where(name: /(#{Regexp.escape(file_name)})$/, ignored: true).any?
  end

end