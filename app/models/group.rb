class Group
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include GroupLeaders

  field :name, type: String
  field :description, type: String
  field :owner_id, type: BSON::ObjectId
  field :private, type: Boolean, default: false
  field :advertise, type: Boolean, default: false

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

  def member?(user)
    members.where(id: user).any?
  end

  def invited?(user: nil, email: nil)
    return group_invitations.where(user: user).any? if user
    return group_invitations.where(email: email).any? if email
  end

  def can_remove_member?(member, current_user = nil)
    return false if member == owner
    return member == current_user || current_user == owner
  end

end
