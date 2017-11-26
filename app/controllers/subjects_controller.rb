class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :home, :fetch]
  before_action :authenticate_admin!, except: [:index, :show, :home, :fetch]
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_subject_id

  def index
    @name = params[:name]
  end

  def fetch
    @subjects = Subject.includes(:children, :interests).filter(filters_params)
      .search(search_params).page(params[:page]).per(10)
    render @subjects
  end

  def home
    @featured = Subject.where(featured: true)
  end

  def show
  end

  def new
    @subject = Subject.new
  end

  def edit
  end

  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      redirect_to @subject, notice: 'Subject was successfully created.'
    else
      render :new
    end
  end

  def update
    if @subject.update(subject_params)
      redirect_to @subject, notice: 'Subject was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @subject.destroy
    redirect_to subjects_url, notice: 'Subject was successfully destroyed.'
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def filters_params
    params[:filters]? params.require(:filters).permit(:order_by, :featured) : {}
  end

  def search_params
    params[:search]? params.require(:search).permit(:name) : {}
  end

  def subject_params
    params.require(:subject).permit(:name, :headline, :description,
      :featured, :parent_id, :thumbnail, :thumbnail_cache, :remove_thumbnail,
      :banner, :banner_cache, :remove_banner)
  end

  def wrong_subject_id
    flash[:danger] = 'Wrong id provided'
    redirect_to subjects_path
  end
end
