class PostsController < ApplicationController
  before_action :set_organization
  before_action :set_post, only: [:show, :edit, :update]
  before_action :authorizate_admin, except: [:show, :index]

  def index
    @posts = @organization.posts
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = @organization.posts.build(post_params)
    if @post.save
      redirect_to organization_post_url(@organization, @post), notice: "Post was created"
    else
      render :new
    end
  end

  def update
    if @post.update_attributes(post_params)
      redirect_to organization_post_url(@organization, @post), notice: "Post was updated"
    else
      render :edit
    end
  end

  def destroy
  end

  private

  def authorizate_admin
    unless @organization.has_admin?(current_user)
      redirect_to @organization, notice: "You have no permissions"
    end
  end

  def post_params
    params.require(:post).permit(:title, :body).merge({ user_id: current_user.id })
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end
end
