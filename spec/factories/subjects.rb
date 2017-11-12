FactoryGirl.define do
  factory :subject do
    name { Faker::Name.title }
    headline { Faker::Name.title }
    description { Faker::Name.title }
    featured false
  end
end
