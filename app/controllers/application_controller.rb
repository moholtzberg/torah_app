class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  around_action :set_time_zone, if: :current_user
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:name, :email, :password, :password_confirmation)
    end
  end

  def authenticate_admin!
    redirect_to subjects_url, notice: "Only for admins" unless current_user.admin?
  end

  private

  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
