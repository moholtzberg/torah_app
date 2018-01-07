module LessonsHelper
  def lesson_time(time)
    return nil unless time
    time.strftime('%H:%M %d %B')
  end

  def time_ranges_json_for array
    array.map do |range|
      "#{range.begin.strftime('%Y-%m-%dT%H:%M:%S')}..#{range.end.strftime('%Y-%m-%dT%H:%M:%S')}"
    end
  end
end
