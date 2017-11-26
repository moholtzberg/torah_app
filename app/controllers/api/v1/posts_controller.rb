class Api::V1::PostsController < Api::V1::BaseController
  before_action :set_organization
  before_action :set_post, only: %i[show update]
  before_action :authenticate_user!, only: %i[create update]
  before_action :authorizate_admin, only: %i[create update]

  def index
    posts = @organization.posts.order('created_at DESC').page(params[:page])
    render json: posts
  end

  def show
    render json: @post
  end

  def create
    @post = @organization.posts.build(post_params)
    if @post.save
      render json: @post, status: :created
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @post.update_attributes(post_params)
      render json: @post
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  private

  def authorizate_admin
    unless @organization.has_admin?(current_user)
      render json: { errors: { permissions: 'You have no permissions' }}, status: :unauthorized
    end
  end

  def post_params
    params.require(:post).permit(:title, :body).merge(user_id: current_user.id)
  end

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_post
    @post = @organization.posts.find(params[:id])
  end
end
