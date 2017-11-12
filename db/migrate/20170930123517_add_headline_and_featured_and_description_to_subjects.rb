class AddHeadlineAndFeaturedAndDescriptionToSubjects < ActiveRecord::Migration[5.0]
  def change
    add_column :subjects, :description, :text
    add_column :subjects, :headline, :text
    add_column :subjects, :featured, :boolean
  end
end
