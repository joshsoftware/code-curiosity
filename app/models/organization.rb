class Organization
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include Mongoid::Slug

  field :name, type: String
  field :github_handle, type: String
  field :description, type: String
  field :website, type: String
  field :contact, type: String

  # Background sync
  field :last_repo_sync_at,  type: Time

  slug :name

  has_and_belongs_to_many :users
  has_many :repositories

  validates :name, :website, :github_handle, presence: true

  after_create do |org|
    OrgReposJob.perform_later(org)
  end

  def repo_syncing?
    last_repo_sync_at.present? && (Time.now - last_repo_sync_at) < 3600
  end
end
