class AddBannerAndThumbnailToSubjects < ActiveRecord::Migration[5.0]
  def change
    add_column :subjects, :thumbnail, :string
    add_column :subjects, :banner, :string
  end
end
