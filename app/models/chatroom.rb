class Chatroom < ApplicationRecord
  has_many :participatings
  has_many :users, through: :participatings
  has_many :messages, dependent: :destroy

  def add_participant user
    participatings.create(user_id: user.id)
  end

  def self.find_by_participants(user_a, user_b)
    self.joins(:users).where("(users.id = ?)", user_a.id).select do |chat|
      chat.users.select{ |user| user.id == user_b.id }.any?
    end.first
  end
end
