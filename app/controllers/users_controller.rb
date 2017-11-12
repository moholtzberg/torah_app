class UsersController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_user_id

  def fetch_users
    @users = User.filter(filters_params).search(search_params)
    render @users
  end

  def index
  end

  def show
    @user = User.find(params[:id])
    @memberships = @user.memberships.where.not(confirmed_at: nil).includes(:organization)
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

  def filters_params
    params[:filters]? params.require(:filters).permit(:sort, :online, :order_by) : {}
  end

  def search_params
    params[:search]? params.require(:search).permit(:name, :country, :city, :state) : {}
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def wrong_user_id
    flash[:danger] = 'Wrong id provided'
    redirect_to users_path
  end

end
