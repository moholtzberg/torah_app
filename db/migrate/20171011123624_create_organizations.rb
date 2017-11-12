class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :headline
      t.text :description
      t.string :thumbnail
      t.datetime :confirmed_at
      t.integer :founder_id
      t.string :banner

      t.timestamps
    end

    add_index :organizations, :founder_id
  end
end
