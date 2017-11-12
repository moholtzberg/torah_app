class AddOrganizationIdToChatrooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chatrooms, :organization_id, :integer
    add_index :chatrooms, :organization_id
  end
end
