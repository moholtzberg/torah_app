class LessonsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_id
  before_action :authenticate_user!

  def index
  end

  def fetch_lessons
    render current_user.lessons
  end

  def fetch_subjects
    subjects =  Subject.where("name LIKE ?", "%#{params[:search]}%")
    render partial: "subjects/subject_option", collection: subjects, as: :subject
  end

  def accept_invite
    lesson = Lesson.find(params[:id])
    if lesson.receiver == current_user
      lesson.update_attribute(:confirmed_at, DateTime.now)
      redirect_to user_lessons_path(current_user)
    else
      redirect_to user_lessons_path(current_user), notice: "You cannot accept his invite"
    end
  end

  def decline_invite
    lesson = Lesson.find(params[:id])
    if lesson.receiver == current_user || lesson.sender == current_user
      lesson.destroy
      redirect_to user_lessons_path(current_user)
    else
      redirect_to user_lessons_path(current_user), notice: "You cannot decline this lesson"
    end

  end

  def create
    @user = User.find(params[:user_id])
    @lesson = Lesson.new(lesson_params)
    if @lesson.save
      redirect_to @user, notice: "You have invited this user to study with you"
    else
      render :new
    end
  end

  def new
    @user = User.find(params[:user_id])
    @lesson = Lesson.new(sender_id: current_user.id, receiver_id: @user.id)
  end

  private

  def lesson_params
    params.require(:lesson).permit(:message, :starts_at_time, :ends_at_time,
      :starts_at_date, :ends_at_date, :subject_id, :receiver_id, :sender_id, :recurring)
  end

  def wrong_id
    flash[:danger] = 'Wrong id provided'
    redirect_to user_lessons_url(current_user)
  end
end
