class Api::V1::SubjectsController < Api::V1::BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_subject_id
  before_action :authenticate_user!, only: %i[like unlike]

  def index
    subjects = Subject.filter(filters_params).search(search_params).page(params[:page])
    render json: subjects
  end

  def show
    subject = Subject.find(params[:id])
    render json: subject
  end

  def like
    subject = Subject.find(params[:subject_id])
    interest = current_user.interests.find_by(subject_id: subject.id)
    if interest
      head(:bad_request) && return
    else
      current_user.interests.create(subject_id: subject.id)
      head(:created) && return
    end
  end

  def unlike
    subject = Subject.find(params[:subject_id])
    interest = current_user.interests.find_by(subject_id: subject.id)
    if interest
      interest.destroy
      head(:no_content) && return
    else
      head(:bad_request) && return
    end
  end

  private

  def filters_params
    params[:filters] ? params.require(:filters).permit(:order_by, :featured) : {}
  end

  def search_params
    params[:search] ? params.require(:search).permit(:name) : {}
  end

  def wrong_subject_id
    render json: { errors: [id: 'Wrong subject id provided'] }
  end
end
