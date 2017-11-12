class ChatroomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "chatrooms_#{params['chatroom_id']}_channel"
  end

  def unsubscribed
  end

  def send_message(data)
    current_user.messages.create!(body: data['message'], chatroom_id: data['chatroom_id'])
  end

  def edit_message(data)
    message = Message.find(data['id'])
    if current_user.id == message.user.id
      message.update(body: data['new_message'])
    end
  end

  def start_video_call
    ActionCable.server.broadcast "chatrooms_#{params['chatroom_id']}_channel",
                                 message: video_call_message(current_user)
  end

  private

  def video_call_message(user)
    %(<div>
        <span>#{user.name} has joined to video chat.</span>
        <span class="video-call-link"> Click here to join </span>
      </div>)
  end

  class << self
    def add_participant(chatroom, current_user, user)
      ActionCable.server.broadcast "chatrooms_#{chatroom.id}_channel",
                                   message: add_participant_message(current_user, user)
    end

    private

    def add_participant_message(current_user, user)
      %(<div>
          <span>#{current_user.name} has added #{user.name}.</span>
        </div>)
    end
  end
end
