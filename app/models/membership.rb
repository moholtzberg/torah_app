class Membership < ApplicationRecord
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  enum role: {
    member: 0,
    moderator: 1,
    admin: 2
  }

  belongs_to :user
  belongs_to :organization

  validate :founder_should_be_admin, on: :update
  before_destroy :founder_cannot_leave_organization

  after_commit :add_user_to_organization_chatroom, on: [:create, :update]
  before_destroy :remove_user_from_organization_chatroom

  private

  def add_user_to_organization_chatroom
    user.participatings.create(chatroom_id: organization.chatroom.id) if confirmed_at
  end

  def remove_user_from_organization_chatroom
    user.participatings.find_by(chatroom_id: organization.chatroom.id).destroy if confirmed_at
  end

  def founder_cannot_leave_organization
    if user_id == organization.founder_id
      errors.add(:user_id, "Founder cannot leave organization")
      throw :abort
    end
  end

  def founder_should_be_admin
    errors.add(:user_id, "Founder should be admin") if user_id == organization.founder_id && role != "admin"
  end
end
