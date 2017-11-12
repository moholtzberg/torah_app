FactoryGirl.define do
  factory :post do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph(5) }
    association :user, factory: :user
    association :organization, factory: :organization
  end
end
