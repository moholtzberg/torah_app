class ChatroomsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_id
  before_action :authenticate_user!

  def index
    @chatrooms = current_user.chatrooms
  end

  def show
    @chatroom = Chatroom.find(params[:id])
    redirect_not_participant unless @chatroom.has_participant?(current_user)
    @messages = @chatroom.messages
    @message = Message.new
  end

  def create
    user = User.find(params[:user_id])
    @chatroom = create_room(user) if user
    redirect_to @chatroom
  end

  def add_participant
    chatroom = Chatroom.find(params[:chatroom_id])
    redirect_not_participant unless chatroom.has_participant?(current_user)
    user = User.find(params[:user_id])
    chatroom.add_participant(user)

    ChatroomsChannel.add_participant(chatroom, current_user, user)
  end

  def fetch_users
    chatroom = Chatroom.find(params[:chatroom_id])
    render User.all, locals: { is_invite_link: true, chatroom: chatroom }
  end

  def generate_video_token
    token = Twilio::JWT::AccessToken.new(
      ENV['ACCOUNT_SID'],
      ENV['API_KEY_SID'],
      ENV['API_KEY_SECRET'],
      identity: "#{current_user.name}_#{current_user.id}"
    )

    grant = Twilio::JWT::AccessToken::VideoGrant.new
    grant.room = "chatroom_#{params['chatroom_id']}"
    token.add_grant(grant)

    client = Twilio::REST::Client.new(ENV['API_KEY_SID'], ENV['API_KEY_SECRET'])
    rooms = client.video.rooms.list(unique_name: "chatroom_#{params['chatroom_id']}")

    unless rooms.any?
      client.video.v1.rooms.create(unique_name: "chatroom_#{params['chatroom_id']}", video_codecs: 'H264')
    end

    render json: { token: token.to_jwt }
  end

  private

  def wrong_id
    redirect_to chatrooms_path, notice: 'Wrong id provided'
  end

  def redirect_not_participant
    redirect_to chatrooms_path,
                notice: 'You should be participant of this chatroom'
  end

  def create_room(user)
    chatroom = Chatroom.create
    chatroom.add_participant(user)
    chatroom.add_participant(current_user)
    chatroom
  end
end
