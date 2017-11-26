class FullOraganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :headline, :description, :thumbnail_url, :banner_url, :members_count

  has_one :founder

  def members_count
    object.memberships.confirmed.count
  end
end
