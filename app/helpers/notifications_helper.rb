module NotificationsHelper
  def notification_time time
    return nil unless time
    time.strftime('%d %B')
  end
end
