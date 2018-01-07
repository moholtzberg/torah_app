class User < ApplicationRecord
  include Filterable
  include Searchable
  include PublicActivity::Common

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
  has_many :lessons, foreign_key: :sender_id, dependent: :destroy
  has_many :lessons, foreign_key: :receiver_id, dependent: :destroy
  has_many :foundations, class_name: "Organization", foreign_key: :founder_id
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :confirmed_memberships, -> { confirmed }, class_name: "Membership"
  has_many :confirmed_organizations, source: :organization, through: :confirmed_memberships
  has_many :posts
  has_many :notifications, dependent: :destroy
  has_many :devices, dependent: :destroy

  validates :name, presence: true, length: { in: 5..40 }
  validate :availability_should_be_inside_availability_range, on: :update, if: :availability_is_present?

  has_friendship
  mount_uploader :avatar, AvatarUploader
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :lockable #, :omniauthable
  include DeviseTokenAuth::Concerns::User

  # Devise is not sending confrirmation email on create
  after_commit :send_confirmation_instructions, on: :create
  before_create :set_default_availability

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
    relation = HasFriendship::Friendship.find_relation(self, user)[0]
    relation.status if relation
  end

  def self.sort_by param
    order_params = {
      "oldest" => "created_at ASC",
      "newest" => "created_at DESC"
    }
    self.order(order_params[param])
  end

  def available? time_range
    t = to_availability_week(time_range)
    self.availability.each do |r|
      return true if r.include?(t)
    end
    false
  end

  def unavailable? time_range
    !self.available?(time_range)
  end

  def busy? time_range
    t = to_availability_week(time_range)
    return true if
     self.lessons.exists?([
       "(time && tstzrange(:begin, :end)) AND confirmed_at IS NOT NULL",
       begin: time_range.begin, end: time_range.end
     ]) ||
     self.lessons.exists?([
       "(time && tstzrange(:begin, :end)) AND confirmed_at IS NOT NULL AND recurring IS NOT NULL",
       begin: t.begin, end: t.end
     ])
     false
  end

  private

  def to_availability_week range
    b = range.begin
    e = range.end
    Time.zone.parse("1996-01-01 #{b.to_s(:time)}") + (b.wday - 1).days ..
    Time.zone.parse("1996-01-01 #{e.to_s(:time)}") + (e.wday - 1).days
  end

  def set_default_availability
    a = []
    7.times do |i|
      range = Time.zone.parse('1996-01-01 00:00') + i.days..Time.zone.parse('1996-01-01 24:00') + i.days
      a << range
    end
    self.availability = a
  end

  def availability_is_present?
    @availability
  end

  def send_confirmation_instructions
      unless @raw_confirmation_token
        generate_confirmation_token!
      end

      opts = pending_reconfirmation? ? { to: unconfirmed_email } : { }
      send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
    end

  def availability_should_be_inside_availability_range
    availability_range = Time.zone.parse("1996-01-01 00:00")..
                         Time.zone.parse("1996-01-08 24:00")
    availability.each do |r|
      errors.add(:availability, "Invalid availability ranges are provided") unless
        r.begin.between?(availability_range.begin, availability_range.end) &&
        r.end.between?(availability_range.begin, availability_range.end)
    end
  end
end
