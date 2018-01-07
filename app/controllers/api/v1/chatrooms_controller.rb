class Api::V1::ChatroomsController < Api::V1::BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_id
  before_action :authenticate_user!
  before_action :set_chatroom, except: [:index, :create]
  before_action :authorize_participant, except: [:index, :create]

  def index
    chatrooms = current_user.chatrooms.page(params[:page])
    render json: chatrooms
  end

  def show
    render json: @chatroom
  end

  def messages
    render json: @chatroom.messages.page(params[:page])
  end

  def create
    user = User.find(params[:user_id])
    chatroom = Chatroom.find_by_participants(current_user, user) || create_room(user)
    render json: chatroom, status: :created
  end

  def add_participant
    user = User.find(params[:user_id])
    @chatroom.add_participant(user)
    ChatroomsChannel.add_participant(@chatroom, current_user, user)
    head :created and return
  end

  def video_token
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

  def set_chatroom
    @chatroom = Chatroom.find(params[:chatroom_id] || params[:id])
  end

  def authorize_participant
    unless @chatroom.has_participant?(current_user)
      render json: { errors: { permissions: "You have no permissions" }}, status: :unauthorized
    end
  end

  def create_room(user)
    chatroom = Chatroom.create
    chatroom.add_participant(user)
    chatroom.add_participant(current_user, notify: false)
    chatroom
  end
end
