class Api::V1::NotificationsController < Api::V1::BaseController
  rescue_from ActiveRecord::RecordNotFound, with: :wrong_notification_id
  before_action :authenticate_user!

  def index
    if params[:limit]
      notifications = current_user.notifications.order("created_at DESC").page(0).limit(params[:limit])
    else
      notifications = current_user.notifications.order("created_at DESC").page(params[:page])
    end
    render json: notifications
  end

  def destroy
    notification = current_user.notifications.find(params[:id])
    notification.destroy if notification
    head :no_content and return
  end

  def mark_as_read
    notifications = current_user.notifications.unread
    notifications.update_all(read_at: Time.current)
    head 200 and return
  end

  private

  def wrong_notification_id
    render json: { errors: { id: "Wrong notification id provided" }}, status: :bad_request
  end

  def notification_message
    {
      body: params[:message],
      url: chatrooms_url
    }.to_json
  end
end
