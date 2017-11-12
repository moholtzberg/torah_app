FactoryGirl.define do
  factory :membership do
    association :user, factory: :user
    association :organization, factory: :organization
    role :member
  end
end
