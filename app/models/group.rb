class Group
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :name, type: String
  field :description, type: String
  field :owner_id, type: BSON::ObjectId

  has_and_belongs_to_many :members, class_name: 'User', inverse_of: 'groups'
  has_many :group_invitations

  validates :name, :description, presence: true

  accepts_nested_attributes_for :group_invitations, allow_destroy: true

  def owner
    @owner ||= User.find(self.owner_id)
  end

  def owner=(user)
    self.owner_id = user.id
  end

  def accept_invitation(token)
    invitation = group_invitations.where(token: token).first

    return false unless invitation

    invitation.set(accepted_at: Time.now)
    self.members << invitation.user

    return true
  end

end
