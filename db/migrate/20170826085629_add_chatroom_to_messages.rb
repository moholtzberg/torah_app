class AddChatroomToMessages < ActiveRecord::Migration[5.0]
  def change
    add_reference(:messages, :chatroom, index: true)
  end
end
