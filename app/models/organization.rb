class Organization < ApplicationRecord
  include Filterable
  include Searchable

  scope :order_by, -> (param) { sort_by(param) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  belongs_to :founder, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :posts, dependent: :destroy
  has_one :chatroom, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :headline, presence: true
  validates :description, presence: true

  mount_uploader :thumbnail, ThumbnailUploader
  mount_uploader :banner, BannerUploader

  after_create :create_organization_chatroom
  after_create :create_founder_membership

  def members
    users.includes(:memberships)
      .where.not(memberships: { confirmed_at: nil })
      .where(memberships: { organization_id: id })
  end

  def candidates
    users.includes(:memberships)
      .where(memberships: { confirmed_at: nil, organization_id: id })
  end

  def role_of user
    membership = memberships.where.not(confirmed_at: nil).find_by(user_id: user.id)
    return membership.role if membership
  end

  def has_admin? user
    role_of(user) == "admin"
  end

  def has_member? user
    return true if role_of(user)
  end

  def has_candidate? user
    memberships.find_by(user_id: user.id, confirmed_at: nil)
  end

  def has_founder? user
    founder_id == user.id
  end

  def params_url
    name.downcase.gsub(/ /, "-")
  end

  private

  def create_organization_chatroom
    create_chatroom
  end

  def create_founder_membership
    founder.memberships.create(organization_id: id, confirmed_at: Time.current, role: "admin")
  end

  def self.sort_by param
    order_params = {
      "oldest" => "created_at ASC",
      "newest" => "created_at DESC"
    }
    self.order(order_params[param])
  end
end
