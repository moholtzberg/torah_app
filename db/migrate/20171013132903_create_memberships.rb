class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :role, default: 0

      t.timestamps
    end

    add_index :memberships, :user_id
    add_index :memberships, :organization_id
  end
end
