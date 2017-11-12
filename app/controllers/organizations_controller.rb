class OrganizationsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_organization, only: [:show]
  before_action :set_organization_by_name, only: [:show_by_name]
  before_action :authorizate_founder, only: [:show, :show_by_name], unless: :organization_is_confirmed_or_current_user_is_admin

  def index
  end

  def fetch
    render Organization.confirmed.filter(filters_params).search(search_params),
      current_user: current_user
  end

  def show
    @posts = @organization.posts
  end

  def show_by_name
    @posts = @organization.posts
    render :show
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = current_user.foundations.build(organization_params)
    if @organization.save
      redirect_to organizations_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(
      :name, :headline, :description, :banner, :thumbnail, :thumbnail_cache,
      :remove_thumbnail, :banner_cache, :remove_banner)
  end

  def set_organization_by_name
    p name = params[:organization_name].gsub(/-/, " ")
    @organization = Organization.where('lower(name) = ?', name.downcase).first
  end

  def filters_params
    params[:filters]? params.require(:filters).permit(:order_by) : {}
  end

  def search_params
    params[:search]? params.require(:search).permit(:name) : {}
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_is_confirmed_or_current_user_is_admin
    @organization.confirmed_at || current_user.admin?
  end

  def authorizate_founder
    unless current_user && @organization.founder.id == current_user.id
      redirect_to organizations_path, notice: "You have no permissions"
    end
  end
end
