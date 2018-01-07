class LessonsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_id
  before_action :authenticate_user!

  def index
  end

  def check_if_current_user_is_available
    if current_user.available?(lesson_time)
      render json: { message: "You are available on that time" }
    else
      render json: { message: "You are not available on that time" }, status: :bad_request
    end
  end

  def fetch
    render Lesson.where(sender_id: current_user.id)
  end

  def subjects
    subjects = Subject.where("lower(name) LIKE ?", "%#{params[:search].downcase}%").map { |subject| {label: subject.name, value: subject.id } }
    render json: subjects
  end

  def accept_invite
    lesson = Lesson.find(params[:id]).includes(:receiver)
    if lesson.receiver == current_user
      lesson.update_attribute(:confirmed_at, Time.current)
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
    @subject = Subject.find(params[:lesson][:subject_id]) if params[:lesson][:subject_id]
    @lesson = Lesson.new(lesson_params)
    if @lesson.save
      redirect_to @user, notice: "You have invited this user to study with you"
    else
      p params[:lesson][:starts_at_date]
      render :new
    end
  end

  def new
    @user = User.find(params[:user_id])
    @lesson = Lesson.new(sender_id: current_user.id, receiver_id: @user.id)
  end

  private

  def lesson_time
    starts = Time.zone.parse("#{params[:starts_at_date]} #{params[:starts_at_time]}")
    ends = Time.zone.parse("#{params[:ends_at_date]} #{params[:ends_at_time]}")
    starts..ends
  end

  def lesson_params
    params.require(:lesson).permit(:message, :starts_at_time, :ends_at_time, :private,
      :starts_at_date, :ends_at_date, :subject_id, :receiver_id, :sender_id, :recurring)
  end

  def wrong_id
    flash[:danger] = 'Wrong id provided'
    redirect_to user_lessons_url(current_user)
  end
end
