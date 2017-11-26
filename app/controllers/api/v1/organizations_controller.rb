class Api::V1::OrganizationsController < Api::V1::BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_organization_id
  before_action :authenticate_user!, only: [:create]
  before_action :set_organization, only: [:show]
  before_action :authorizate_founder, only: [:show], unless: :organization_is_confirmed?

  def index
    organizations = Organization.confirmed.filter(filters_params).search(search_params)
    render json: organizations
  end

  def show
    render json: @organization, serializer: FullOraganizationSerializer
  end

  def create
    organization = current_user.foundations.build(organization_params)
    if organization.save
      render json: organization, status: :created
    else
      render json: { errors: organization.errors }, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(
      :name, :headline, :description, :banner, :thumbnail, :thumbnail_cache,
      :remove_thumbnail, :banner_cache, :remove_banner)
  end

  def filters_params
    params[:filters]? params.require(:filters).permit(:order_by) : {}
  end

  def search_params
    params[:search]? params.require(:search).permit(:name) : {}
  end

  def organization_is_confirmed?
    @organization.confirmed_at
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def wrong_organization_id
    render json: { errors: { id: "Wrong organization id provided" }}, status: :bad_request
  end

  def authorizate_founder
    unless current_user && @organization.founder.id == current_user.id
      render json: { errors: { permissions: 'You have no permissions' }}, status: :unauthorized
    end
  end
end
