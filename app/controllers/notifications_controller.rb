class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:limit]
      @notifications = current_user.notifications.order("created_at DESC").page(0).limit(params[:limit])
    else
      @notifications = current_user.notifications.order("created_at DESC").page(params[:page])
    end
    respond_to do |format|
      format.html
      format.json { p render json: @notifications }
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy if @notification
    redirect_to notifications_url
  end

  def mark_as_read
    @notifications = current_user.notifications.unread
    @notifications.update_all(read_at: Time.current)
    render json: { success: true }
  end

  def subscribe
    current_user.devices.destroy_all
    current_user.devices.create!(
      endpoint: params[:subscription][:endpoint],
      p256dh: params[:subscription][:keys][:p256dh],
      auth: params[:subscription][:keys][:auth]
    )
    head :ok
  end

  private

  def notification_message
    {
      body: params[:message],
      url: chatrooms_url
    }.to_json
  end
end
