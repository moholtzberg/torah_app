FactoryGirl.define do
  factory :organization do
    sequence(:name)    { |n| "#{Faker::Team.name}#{n}" }
    headline { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph(10) }
    confirmed_at nil
    association :founder, factory: :user
    banner nil
    thumbnail nil

    factory :confirmed_organization do
      confirmed_at Time.current
    end
  end
end
