class GroupInvitation
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :token, type: String
  field :accepted_at, type: Time

  belongs_to :group
  belongs_to :user

  index({ token: 1 }, { unique: true })

  before_create :set_invitation_token

  after_create :send_invitation

  def set_invitation_token
    self.token = self.class.generate_token
  end

  def self.generate_token
    loop do
      token = SecureRandom.base64(24).tr('0+/=', 'A0lk')
      break token unless where(token: token).exists?
    end
  end

  def send_invitation
    GroupInvitationMailer.invite(self).deliver_later
  end

end
