class AddTypeToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :type_of, :integer, default: 0
  end
end
