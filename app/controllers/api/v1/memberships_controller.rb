class Api::V1::MembershipsController < Api::V1::BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_organization_id
  before_action :set_organization
  before_action :authenticate_user!
  before_action :authorizate_founder, only: [:change_role]
  before_action :authorizate_admin, only: [:accept_invite, :candidates]
  before_action :authorizate_member, only: [:members]

  def send_invite
    if current_user.memberships.find_by(organization_id: @organization.id)
      render json: { errors: { id: "You've already sent invite" }}, status: :bad_request
    else
      current_user.memberships.create(organization_id: @organization.id)
      head :created and return
    end
  end

  def cancel_invite
    membership = current_user.memberships.find_by(organization_id: @organization.id)
    if membership
      membership.destroy
      head :no_content and return
    else
      render json: { errors: { id: "You don't have send invite yet" }}, status: :bad_request
    end
  end

  def accept_invite
    membership = @organization.memberships.find_by(user_id: params[:user_id])
    if membership.update_attributes(confirmed_at: Time.current)
      head 200 and return
    else
      head :bad_request and return
    end
  end

  def members
    members = @organization.members.page(params[:page])
    render json: members
  end

  def candidates
    candidates = @organization.candidates.page(params[:page])
    render json: candidates
  end

  def change_role
    membership = @organization.memberships.find_by(user_id: params[:user_id])
    if membership.update_attributes(role: params[:role])
      head 200 and return
    else
      head :bad_request and return
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def wrong_organization_id
    render json: { errors: { id: "Wrong organization id provided" }}, status: :bad_request
  end

  def authorizate_admin
    unless @organization.has_admin?(current_user)
      render json: { errors: { permissions: "You have no permissions" }}, status: :unauthorized
    end
  end

  def authorizate_founder
    unless @organization.has_founder?(current_user)
      render json: { errors: { permissions: "You have no permissions" }}, status: :unauthorized
    end
  end

  def authorizate_member
    unless @organization.has_member?(current_user)
      render json: { errors: { permissions: "You have no permissions" }}, status: :unauthorized
    end
  end
end
