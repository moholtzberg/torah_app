class Chatroom < ApplicationRecord
  has_many :participatings, dependent: :destroy
  has_many :users, through: :participatings
  has_many :messages, dependent: :destroy
  belongs_to :organization, optional: true

  def add_participant user, options={notify: true}
    return nil if participatings.find_by(user_id: user.id) || organization_id
    participatings.create(user_id: user.id)

    create_add_participant_event_message(user, options[:current_user]) if options[:current_user]

    user.notifications.create(
      message: "You have been invited to chatroom",
      link: Rails.application.routes.url_helpers.chatroom_path(id)
    ) if options[:notify]
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

  def create_end_video_chat_message time, current_user
    create_event_message("Call has ended in #{time}", current_user)
  end

  def notify_participants_about_video_call user
    users.each do |u|
      unless user.id == u.id
        if u.status == "offline"
          u.notifications.create(
            message: "You have been invited to video call",
            link: Rails.application.routes.url_helpers.chatroom_path(id)
          )
        else
          ActionCable.server.broadcast("current_user_#{u.id}_channel",
            type: "video_call",
            user: user.name,
            chatroom: {
              url: Rails.application.routes.url_helpers.chatroom_path(id)
            }
          )
        end
      end
    end
  end

  private

  def create_add_participant_event_message user, current_user
    create_event_message("#{current_user.name} has invited #{user.name}", current_user)
  end

  def create_event_message body, user
    messages.create(type_of: "event", user_id: user.id, body: body)
  end
end
