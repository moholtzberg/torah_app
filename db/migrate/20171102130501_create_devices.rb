class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :endpoint
      t.string :p256dh
      t.string :auth
      t.integer :user_id

      t.timestamps
    end

    add_index :devices, :user_id
  end
end
