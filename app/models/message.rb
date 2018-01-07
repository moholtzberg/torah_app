class Message < ApplicationRecord
  enum type_of: {
    message: 0,
    event: 1
  }

  belongs_to :user
  belongs_to :chatroom
  has_many :users, through: :chatroom

  validates :body, presence: true, length: { in: 1..200 }

  after_create :notify_chatroom_participants, unless: :event?
  after_commit { MessageBroadcastJob.perform_later(self) }

  def event?
    type_of == "event"
  end
  
  private

  def notify_chatroom_participants
    users.where.not(id: user_id).each do |u|
      u.notifications.create(
        message: "You got new message",
        link: Rails.application.routes.url_helpers.chatroom_path(chatroom_id)
      )
    end
  end
end
