FactoryGirl.define do
  factory :membership do
    association :user, factory: :user
    association :organization, factory: :organization
    role :member
    confirmed_at nil

    factory :confirmed_membership do
      confirmed_at Time.current
    end
  end
end
