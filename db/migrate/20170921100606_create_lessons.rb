class CreateLessons < ActiveRecord::Migration[5.0]
  def change
    create_table :lessons do |t|
      t.text :message
      t.integer :sender_id
      t.integer :receiver_id
      t.references :subject, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :lessons, :sender_id
    add_index :lessons, :receiver_id
  end
end
