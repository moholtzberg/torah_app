class ChatroomsChannel < ApplicationCable::Channel

  def subscribed
    stream_from "chatrooms_#{params['chatroom_id']}_channel"
  end

  def unsubscribed
  end

  def send_message(data)
    current_user.messages.create!(body: data['message'], chatroom_id: data['chatroom_id'])
  end

  def start_video_call
    StartVideoCallBroadcastJob.perform_later(current_user, params['chatroom_id'])
  end
end
