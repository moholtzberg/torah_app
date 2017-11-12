class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  around_action :set_time_zone, if: :current_user
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update) do |u|
      availability = u[:availability].map.with_index do |r, i|
        ends = r.split('..')
        s = Time.zone.parse("1996-01-01 #{ends[0]}") + i.days
        e = Time.zone.parse("1996-01-01 #{ends[1]}") + i.days
        s..e
      end

      u.permit(:name, :email,
        :current_password, :avatar, :avatar_cache, :remove_avatar, :country, :city, :state,
        :time_zone).merge({ availability: availability })
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
