class FullUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :avatar_url, :admin, :moderator, :status

  has_many :organizations do
    object.confirmed_organizations
  end

  has_one :chatroom do
    Chatroom.find_by_participants(scope, object)
  end
end
