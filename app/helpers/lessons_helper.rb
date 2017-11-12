module LessonsHelper
  def lesson_time(time)
    return nil unless time
    time.strftime('%H:%M %d %B')
  end
end
