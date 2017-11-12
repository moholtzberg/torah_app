class User < ApplicationRecord
  include Filterable
  include Searchable

  scope :order_by, -> (param) { sort_by(param) }

  enum status: {
    offline: 0,
    online: 1,
    away: 2
  }

  has_many :interests, dependent: :destroy
  has_many :participatings, dependent: :destroy
  has_many :subjects, through: :interests
  has_many :chatrooms, through: :participatings
  has_many :messages
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :lessons, foreign_key: :sender_id, dependent: :destroy
  has_many :lessons, foreign_key: :receiver_id, dependent: :destroy
  has_many :foundations, class_name: "Organization", foreign_key: :founder_id
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :posts
  has_many :notifications, dependent: :destroy
  has_many :devices, dependent: :destroy

  validates :name, presence: true, length: { in: 5..40 }
  validate :availability_should_be_inside_availability_range

  mount_uploader :avatar, AvatarUploader
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :lockable, :omniauthable


  def disappear
    update_attribute(:status, 0)
  end

  def appear
    update_attribute(:status, 1)
  end

  def away
    update_attribute(:status, 2)
  end

  def relation_with user
    has_invited_user = Friendship.find_by(user_id: id, friend_id: user.id)
    invited_by_user = Friendship.find_by(user_id: user.id, friend_id: id)
    return "friends" if has_invited_user && invited_by_user
    return "invited_user" if has_invited_user && !invited_by_user
    return "invited_by_user" if !has_invited_user && invited_by_user
    return "not_friends" if !has_invited_user && !invited_by_user
  end

  def self.sort_by param
    order_params = {
      "oldest" => "created_at ASC",
      "newest" => "created_at DESC"
    }
    self.order(order_params[param])
  end

  private

  def availability_should_be_inside_availability_range
    availability_range = Time.parse("1996-01-01 00:00")..
                         Time.parse("1996-01-08 24:00")
    availability.each do |r|
      errors.add(:availability, "Invalid availability ranges are provided") unless
        r.begin.between?(availability_range.begin, availability_range.end) &&
        r.end.between?(availability_range.begin, availability_range.end)
    end
  end
end
