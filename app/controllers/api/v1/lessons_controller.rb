class Api::V1::LessonsController < Api::V1::BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_id
  before_action :authenticate_user!

  def index
    render json: current_user.lessons.page(params[:page])
  end

  def subjects
    subjects =  Subject.where("name LIKE ?", "%#{params[:name]}%").page(params[:page])
    render json: subjects
  end

  def update
    lesson = Lesson.find(params[:id])
    if lesson.receiver == current_user
      lesson.update_attribute(:confirmed_at, DateTime.now)
      render json: lesson
    else
      render json: { errors: { receiver: "You are not receiver"}}, status: :bad_request
    end
  end

  def destroy
    lesson = Lesson.find(params[:id])
    if lesson.receiver == current_user || lesson.sender == current_user
      lesson.destroy
      head :no_content and return
    else
      head :bad_request and return
    end
  end

  def create
    lesson = Lesson.new(lesson_params)
    if lesson.save
      render json: lesson, status: :created
    else
      render json: { errors: lesson.errors }, status: :unprocessable_entity
    end
  end

  private

  def lesson_params
    params.require(:lesson).permit(:message, :starts_at_time, :ends_at_time,
      :starts_at_date, :ends_at_date, :subject_id, :receiver_id, :recurring).merge({sender_id: current_user.id})
  end
end
