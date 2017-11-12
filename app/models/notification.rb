class Notification < ApplicationRecord
  scope :unread, -> { where(read_at: nil) }

  belongs_to :user

  after_commit :push_web_notification
  after_commit :broadcast_notification

  private

  def push_web_notification
    user.devices.each do |device|
      Webpush.payload_send(
      message: notification_message,
      endpoint: device.endpoint,
      p256dh: device.p256dh,
      auth: device.auth,
      api_key: ENV['GOOGLE_CLOUD_MESSAGE_API_KEY'],
      vapid: {
        subject: "/",
        public_key: ENV['VAPID_PUBLIC_KEY'],
        private_key: ENV['VAPID_PRIVATE_KEY']
        }
      )
    end
  end

  def notification_message
  {
    body: message,
    url: link
  }.to_json
  end


  def broadcast_notification
    ActionCable.server.broadcast "current_user_#{user_id}_channel",
                                 notification: render_notification(self)
  end

  def render_notification(notification)
      ApplicationController.renderer.render(partial: 'notifications/notification', locals: { notification: notification })
  end
end
