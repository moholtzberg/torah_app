class ChatroomsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_id
  before_action :authenticate_user!
  before_action :authorize_participant!, except:[:index, :create]

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

  def add_participant
    user = User.find(params[:user_id])
    @chatroom.add_participant(user, current_user: current_user)
  end

  def fetch_users
    render User.all, locals: { is_invite_link: true, chatroom: @chatroom }
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
      @chatroom.notify_participants_about_video_call(current_user)

    end

    render json: { token: token.to_jwt }
  end

  def end_video_chat
    client = Twilio::REST::Client.new(ENV['API_KEY_SID'], ENV['API_KEY_SECRET'])
    rooms = client.video.rooms.list(unique_name: "chatroom_#{@chatroom.id}")
    if rooms.any?
      time = Time.at(Time.current - rooms[0].date_created).utc.strftime("%H:%M:%S")
      @chatroom.create_end_video_chat_message(time, current_user)
    end
  end

  private

  def authorize_participant!
    @chatroom = Chatroom.find(params[:chatroom_id] || params[:id])
    redirect_not_participant unless @chatroom.has_participant?(current_user)
  end

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
    chatroom.add_participant(current_user, notify: false)
    chatroom
  end
end
