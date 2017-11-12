FactoryGirl.define do
  factory :interest do
    association :user, factory: :user
    association :subject, factory: :subject
  end
end
