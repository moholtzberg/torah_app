FactoryGirl.define do
  factory :participating do
    association :user, factory: :user
    association :chatroom, factory: :chatroom
  end
end
