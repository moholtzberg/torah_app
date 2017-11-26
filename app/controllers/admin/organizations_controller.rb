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

  def fetch
    organizations = Organization.filter(filters_params).search(search_params)
      .page(params[:page]).per(10)
    render organizations,
      current_user: current_user
  end

  private

  def filters_params
    params[:filters]? params.require(:filters).permit(:order_by, :unconfirmed, :confirmed) : {}
  end

  def search_params
    params[:search]? params.require(:search).permit(:name) : {}
  end
end
