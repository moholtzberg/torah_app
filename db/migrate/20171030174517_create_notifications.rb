class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.text :message
      t.integer :user_id
      t.string :link
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :user_id
  end
end
