class StartVideoCallBroadcastJob < ApplicationJob
  queue_as :default

  def perform(user, chatroom_id)
    ActionCable.server.broadcast "chatrooms_#{chatroom_id}_channel",
                                 message: video_call_message(user)
  end

  private

  def video_call_message(user)
    %(<div>
        <span>#{user.email} has joined to video chat.</span>
        <span class="video-call-link"> Click here to join </span>
      </div>)
  end
end
