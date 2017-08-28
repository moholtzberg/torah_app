class CreateParticipatings < ActiveRecord::Migration[5.0]
  def change
    create_table :participatings do |t|
      t.references :user, foreign_key: true
      t.references :chatroom, foreign_key: true

      t.timestamps
    end
  end
end
