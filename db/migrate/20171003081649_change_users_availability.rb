class ChangeUsersAvailability < ActiveRecord::Migration[5.0]
  def change
    remove_column(:users, :availability)
    add_column(:users, :availability, :tstzrange, array: true)
  end
end
