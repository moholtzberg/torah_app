FactoryGirl.define do
  factory :notification do
    message "MyText"
    association :user, factory: :user
    link "MyString"
    read_at Time.current
  end
end
