class AddAvailabilityToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :availability, :string,
      default: "12:00am-12:00am,12:00am-12:00am,12:00am-12:00am,12:00am-12:00am,12:00am-12:00am,12:00am-12:00am,12:00am-12:00am"
  end
end
