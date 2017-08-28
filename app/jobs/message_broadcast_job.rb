class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast "chatrooms_#{message.chatroom.id}_channel",
                                 message: render_message(message)
  end

  private

  def render_message(message)
    "<div class='message'>
      #{message.body}
      <span class='text-muted'>#{message.user.email} at #{message.created_at}</span><br>
    </div>"
  end
end
