class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  after_create :notify_friend

  after_update :notify_user

  private

  def notify_friend
    friend.notifications.create(
      message: "#{user.name} want's to be your friend",
      link: Rails.application.routes.url_helpers.user_path(user.id)
    )
  end
end
