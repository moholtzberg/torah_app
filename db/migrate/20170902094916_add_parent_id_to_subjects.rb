class AddParentIdToSubjects < ActiveRecord::Migration[5.0]
  def change
    add_column :subjects, :parent_id, :integer
    add_index :subjects, :parent_id
  end
end
