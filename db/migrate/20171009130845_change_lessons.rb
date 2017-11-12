class ChangeLessons < ActiveRecord::Migration[5.0]
  def change
    remove_column(:lessons, :starts_at)
    remove_column(:lessons, :ends_at)
    add_column(:lessons, :time, :tstzrange)
  end
end
