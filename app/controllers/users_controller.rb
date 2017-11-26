class UsersController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_user_id

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

  def fetch_users
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
      Interest.create(user_id: current_user.id, subject_id: subject.id)
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

  def add_friend
    user = User.find(params[:id])
    if user
      current_user.friendships.create(friend_id: user.id)
      redirect_to user
    end
  end

  def remove_friend
    user = User.find(params[:id])
    if user
      current_user.friendships.find_by(friend_id: user.id).destroy
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

    params.require(:user).permit(:name, :avatar, :avatar_cache, :remove_avatar, :country, :city, :state,
      :time_zone).merge({ availability: availability })
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def filters_params
    params[:filters]? params.require(:filters).permit(:sort, :online, :order_by) : {}
  end

  def search_params
    params[:search]? params.require(:search).permit(:name, :country, :city, :state) : {}
  end

  def wrong_user_id
    flash[:danger] = 'Wrong id provided'
    redirect_to users_path
  end

end
