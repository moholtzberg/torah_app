class Post < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :title, presence: true
  validates :body, presence: true
end
