class AddPrivateToLessons < ActiveRecord::Migration[5.0]
  def change
    add_column :lessons, :private, :boolean, default: true
  end
end
