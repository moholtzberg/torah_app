class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:add_subject]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @chatroom = Chatroom.find_by_participants(current_user, @user)
  end

  def add_subject
    subject = Subject.find(params[:id])
    unless current_user.subjects.include?(subject)
      Interest.create(user_id: current_user.id, subject_id: subject.id)
      redirect_to subjects_url, notice: 'Subject was successfully added to your favorites.'
    else
      redirect_to subjects_url, notice: 'You already have added that subject to your favorites.'
    end
  end

  private

  def user_params
    pararm.require(:user).permit(:email, :password, :password_confirmation)
  end

end
