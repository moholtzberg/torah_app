class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.integer :organization_id

      t.timestamps
    end

    add_index :posts, :user_id
    add_index :posts, :organization_id
  end
end
