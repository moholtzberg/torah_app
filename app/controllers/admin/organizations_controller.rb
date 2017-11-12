class Admin::OrganizationsController < AdminController
  def confirm
    organization = Organization.find(params[:organization_id])
    if organization.update_attributes(confirmed_at: Time.current)
      redirect_to admin_organizations_path
    else
      redirect_to admin_organizations_path
    end
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def index
    @organizations = Organization.includes(:founder)
  end
end
