class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :message, :link
end
