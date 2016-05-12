class Organization
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include Mongoid::Slug

  field :gh_id,         type: String
  field :github_handle, type: String
  field :name,          type: String
  field :company,       type: String
  field :description,   type: String
  field :website,       type: String
  field :blog,          type: String
  field :location,      type: String
  field :email,         type: String
  field :avatar_url,    type: String

  # Background sync
  field :last_repo_sync_at,  type: Time

  slug { |obj| obj.github_handle }

  has_and_belongs_to_many :users
  has_many :repositories
  has_many :commits
  has_many :activities

  validates :github_handle, presence: true, uniqueness: true

  before_create :set_info

  after_create do |org|
    OrgReposJob.perform_later(org)
  end

  def repo_syncing?
    last_repo_sync_at.present? && (Time.now - last_repo_sync_at) < 3600
  end

  def set_info
    ['avatar_url', 'description', 'name', 'company', 'blog', 'location', 'email'].each do |f|
      self[f] = info[f]
    end
    self.gh_id = info.id
  end

  def info
    @info ||= GITHUB.orgs.get(github_handle)
  end

  def self.setup(github_handle, admin)
    Organization.create(github_handle: github_handle).tap{|o| o.users << admin }
  end
end
