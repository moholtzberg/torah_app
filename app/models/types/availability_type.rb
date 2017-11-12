class Types::AvailabilityType < ActiveRecord::Type::String

  def serialize value
    return value if value == ""
     a = []
     value.each do |k, v|
       a << "#{v[:from]}-#{v[:to]}"
     end
     a.join(",")
  end

  def deserialize value
    p value
    value.map {|r|
      p r
    }
  end

  def cast value
    value
  end

  private

  def days
    [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  end
end
