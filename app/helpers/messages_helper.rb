module MessagesHelper
  def message_time(time)
    time.strftime('%H:%M:%S %d %B %Y')
  end
end
