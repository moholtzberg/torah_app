class User < ApplicationRecord
  has_many :interests
  has_many :participatings
  has_many :subjects, through: :interests
  has_many :chatrooms, through: :participatings
  has_many :messages

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :lockable, :omniauthable
end
