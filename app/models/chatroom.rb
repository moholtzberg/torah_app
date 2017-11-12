class Chatroom < ApplicationRecord
  has_many :participatings, dependent: :destroy
  has_many :users, through: :participatings
  has_many :messages, dependent: :destroy
  belongs_to :organization, optional: true

  def add_participant user
    return nil if participatings.find_by(user_id: user.id) || organization_id
    participatings.create(user_id: user.id)
    user.notifications.create(
      message: "You have been invited to chatroom",
      link: Rails.application.routes.url_helpers.chatroom_path(id)
    )
  end

  def self.find_by_participants(user_a, user_b)
    return nil unless user_a and user_b
    user_a.chatrooms.includes(:users)
      .where(users: {id: user_b.id})
      .where(
        '(SELECT Count(*) FROM participatings WHERE participatings.chatroom_id = chatrooms.id) = 2'
      ).first
  end

  def participants_name_without(user)
    name = ""
    users.each do |u|
      unless user == u
        name <<  u.name + " "
      end
    end
    return name
  end

  def has_participant?(user)
    participatings.find_by(user_id: user.id)
  end
end
