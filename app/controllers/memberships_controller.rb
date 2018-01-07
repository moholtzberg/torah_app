class MembershipsController <ApplicationController
  before_action :set_organization
  before_action :authenticate_user!
  before_action :authorizate_founder, only: [:change_role]
  before_action :authorizate_admin, only: [:accept_invite]
  before_action :authorizate_member, only: [:members]

  def send_invite
    unless current_user.memberships.find_by(organization_id: @organization.id)
      current_user.memberships.create(organization_id: @organization.id)
      redirect_to organization_url(@organization)
    else
      redirect_to organization_url(@organization), notice: "Something gone wrong"
    end
  end

  def cancel_invite
    membership = current_user.memberships.find_by(organization_id: @organization.id)
    if membership
      membership.destroy
      redirect_to organization_url(@organization)
    else
      redirect_to organization_url(@organization), notice: "Something gone wrong"
    end
  end

  def accept_invite
    user = User.find(params[:user_id])
    membership = @organization.memberships.find_by(user_id: user.id)
    if membership.update_attributes(confirmed_at: Time.current)
      @organization.create_activity(key: 'organization.accept_invite', owner: user)
      redirect_to organization_members_url(@organization), notice: "User is added to organization"
    else
      redirect_to organization_members_url(@organization), notice: "Something gone wrong"
    end
  end

  def members
    @members = @organization.members
    @candidates = @organization.candidates
  end

  def change_role
    membership = @organization.memberships.find_by(user_id: params[:user_id])
    if membership.update_attributes(role: params[:role])
      redirect_to organization_members_url(@organization), notice: "Permissions are granted"
    else
      redirect_to organization_members_url(@organization), notice: "Something gone wrong"
    end
  end

  private

  def set_organization
    begin
      @organization = Organization.find(params[:organization_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to organizations_url, notice: "Wrong organization id provided"
    end
  end

  def authorizate_admin
    unless @organization.founder_id == current_user.id || @organization.memberships.find_by(user_id: current_user.id, role: :admin)
      redirect_to organizations_path, notice: "You have no permissions"
    end
  end

  def authorizate_founder
    unless @organization.founder_id == current_user.id
      redirect_to organizations_path, notice: "You have no permissions"
    end
  end

  def authorizate_member
    unless @organization.founder_id == current_user.id || @organization.memberships.exists?(["user_id = :id AND confirmed_at IS NOT NULL", id: current_user.id])
      redirect_to organizations_path, notice: "You have no permissions"
    end
  end
end
