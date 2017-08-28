class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_participant, only: [:show]

  def index
    @chatrooms = current_user.chatrooms
  end

  def show
    @messages = @chatroom.messages
    @message = Message.new
  end

  def create
    user = User.find(params[:user_id])
    @chatroom = create_room(user) if user
    redirect_to @chatroom
  end

  def generate_video_token
    token = Twilio::JWT::AccessToken.new(
      ENV["ACCOUNT_SID"],
      ENV["API_KEY_SID"],
      ENV["API_KEY_SECRET"],
      identity: current_user.email)
      
    grant = Twilio::JWT::AccessToken::VideoGrant.new
    grant.room = "chatroom_#{params["chatroom_id"]}"
    token.add_grant(grant)

    render json: {token: token.to_jwt}
  end

  private

  def authenticate_participant
    @chatroom = Chatroom.find(params[:id])
  end

  def create_room(user)
    chatroom = Chatroom.create
    chatroom.add_participant(user)
    chatroom.add_participant(current_user)
    chatroom
  end
end
