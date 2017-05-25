class SponsorerDetail
  include Mongoid::Document
  include Mongoid::Paperclip

  field :sponsorer_type, type: String
  field :payment_plan, type: String
  field :publish_profile, type: Boolean, default: false
  field :stripe_customer_id, type: String
  field :stripe_subscription_id, type: String
  field :subscribed_at, type: DateTime
  field :subscription_expires_at, type: DateTime

  has_mongoid_attached_file :avatar, 
    path: ':rails_root/public/system/sponsorer/:id/:style/:filename',
    url: '/system/sponsorer/:id/:style/:filename',
    :styles => { :default => "300x300>"}

  belongs_to :user

  validates :sponsorer_type, :user, :payment_plan, :stripe_customer_id, :stripe_subscription_id, presence: true
  validates :sponsorer_type, :inclusion => { :in => ['INDIVIDUAL','ORGANIZATION'] }
  validates :payment_plan, :inclusion => { :in => SPONSOR['individual'].keys }
  # validates :publish_profile, :inclusion => { :in => [true, false] }
  # validates_attachment :avatar, presence: true,
  #   content_type: { content_type: /\Aimage\/.*\Z/ },
  #   file_name: { matches: [/png\Z/, /jpe?g\Z/] }
  #   # size: { in: 0..10.kilobytes }
  # validate attachment presence
  # validates_attachment_presence :avatar
  # Validate filename
  validates_attachment_file_name :avatar, matches: [/png\Z/, /jpe?g\Z/]
  # Validate content type
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  after_create :update_user_as_sponsor

  private

  def update_user_as_sponsor
    @user = self.user
    @role = Role.find_or_create_by(name: 'Sponsorer')
    @user.roles << @role unless @user.is_sponsorer?
    @user.set({is_sponsorer: true})
  end
end
