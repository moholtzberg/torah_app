class AddConfirmedAtToMemberships < ActiveRecord::Migration[5.0]
  def change
    add_column :memberships, :confirmed_at, :datetime
  end
end
