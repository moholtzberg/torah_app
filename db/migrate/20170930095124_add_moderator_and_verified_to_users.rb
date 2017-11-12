class AddModeratorAndVerifiedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :moderator, :boolean
    add_column :users, :verified, :boolean
  end
end
