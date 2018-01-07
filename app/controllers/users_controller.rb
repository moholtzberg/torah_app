class UsersController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_user_id

  def home
    @activities = PublicActivity::Activity.order("created_at desc")
      .where(owner_id: current_user.friend_ids.push(current_user.id), owner_type: "User")
  end

  def update
    if current_user.update_attributes(user_params)
      redirect_to current_user, notice: "Successfully updated your account"
    else
      render :edit, status: :unprocesable_entity
    end
  end

  def change_password
    if current_user.update_with_password(password_params)
      sign_in current_user, bypass: true
      redirect_to edit_user_url(current_user), notice: "Successfully updated your password"
    else
      render :edit, status: :unprocesable_entity
    end
  end

  def fetch
    @users = User.filter(filters_params).search(search_params).page(params[:page])
    render @users
  end

  def favorites
    subjects = User.find(params[:user_id]).subjects.page(params[:page])
    render partial: "subjects/subject", collection: subjects, as: :subject, locals: { without_nested: true }
  end

  def show
    @user = User.includes(:confirmed_organizations).find(params[:id])
    @chatroom = Chatroom.find_by_participants(current_user, @user)
  end

  def add_subject
    subject = Subject.find(params[:id])
    interest = current_user.interests.find_by(subject_id: subject.id)
    unless interest
      interest = Interest.create(user_id: current_user.id, subject_id: subject.id)
      subject.create_activity(key: 'subject.like', owner: current_user)
      head :created and return
    else
      head :bad_request and return
    end
  end

  def remove_subject
    subject = Subject.find(params[:id])
    interest = current_user.interests.find_by(subject_id: subject.id)
    if interest
      interest.destroy
      head :no_content and return
    else
      head :bad_request and return
    end
  end

  def friend_request
    user = User.find(params[:user_id])
    if user
      current_user.friend_request(user)
      user.notifications.create(
        message: "#{current_user.name} wants to be your friend",
        link: user_path(current_user)
      )
      redirect_to user
    end
  end

  def accept_request
    user = User.find(params[:user_id])
    if user
      current_user.accept_request(user)

      current_user.create_activity(key: 'user.accept_request', owner: user)
      user.create_activity(key: 'user.accept_request', owner: current_user)

      user.notifications.create(
        message: "#{current_user.name} accepted your friend request",
        link: user_path(current_user)
      )
      redirect_to user, notice: "You are friends now"
    end
  end

  def remove_friend
    user = User.find(params[:user_id])
    if user
      current_user.remove_friend(user)
      redirect_to user
    end
  end

  private

  def user_params
    availability = params[:user][:availability].map.with_index do |r, i|
      ends = r.split('..')
      s = Time.zone.parse("1996-01-01 #{ends[0]}") + i.days
      e = Time.zone.parse("1996-01-01 #{ends[1]}") + i.days
      s..e
    end

    params.require(:user).permit(:name, :language, :avatar, :avatar_cache, :remove_avatar, :country, :city, :state,
      :time_zone).merge({ availability: availability })
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def filters_params
    params[:filters]? params.require(:filters).permit(:sort, :online, :order_by) : {}
  end

  def search_params
    params[:search]? params.require(:search).permit(:name, :country, :city, :state, :language) : {}
  end

  def wrong_user_id
    flash[:danger] = 'Wrong id provided'
    redirect_to users_path
  end
end
