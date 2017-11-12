class Subject < ApplicationRecord
  include Filterable
  include Searchable

  scope :featured, -> { where(featured: true) }
  scope :order_by, -> (param) { sort_by(param) }

  has_many :interests, dependent: :destroy
  has_many :users, through: :interests
  belongs_to :parent, class_name: "Subject", optional: true
  has_many :children, class_name: "Subject", foreign_key: :parent_id, dependent: :destroy
  has_many :lessons, dependent: :destroy

  validates :name, presence: true
  validates :headline, presence: true
  validates :description, presence: true

  validate :check_if_parent_id_wont_loop

  mount_uploader :thumbnail, ThumbnailUploader
  mount_uploader :banner, BannerUploader

  private

  def self.sort_by param
    order_params = {
      "oldest" => "created_at ASC",
      "newest" => "created_at DESC"
    }
    self.order(order_params[param])
  end

  def is_inherit_from_child?(id)
    self.children.each do |c|
      return true if c.id == id || c.is_inherit_from_child?(id)
    end
    return false
  end

  def check_if_parent_id_wont_loop
    errors.add(:parent_id, "You cannot inherit subject from himself") if parent_id == id
    errors.add(:parent_id, "You cannot inherit subject from his child") if parent_id && is_inherit_from_child?(parent_id)
  end
end
