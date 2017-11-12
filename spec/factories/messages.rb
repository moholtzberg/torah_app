FactoryGirl.define do
  factory :message do
    body { Faker::Name.title }
    association :user, factory: :user
    association :chatroom, factory: :chatroom
  end
end
