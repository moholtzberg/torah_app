class AddRecurringToLessons < ActiveRecord::Migration[5.0]
  def change
    add_column :lessons, :recurring, :boolean
  end
end
