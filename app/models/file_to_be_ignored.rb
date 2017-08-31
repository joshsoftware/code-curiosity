class FileToBeIgnored
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :programming_language, type: String
  field :ignored, type: Boolean, default: false
  field :count, type: Integer, default: 0
  field :highest_score, type: Float, default: 0

  validates :name, presence: true

  def self.name_exist?(file_path)
    file_name = File.basename(file_path)

    return false if file_name.blank?

    where(name: /(#{::Regexp.escape(file_name)})$/).first
  end

end
