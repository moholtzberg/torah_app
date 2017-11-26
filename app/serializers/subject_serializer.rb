class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :headline, :description, :featured, :thumbnail_url, :banner_url, :liked

  def liked
    scope && scope.interests.find_by(subject_id: object.id) ? true : false
  end
end
