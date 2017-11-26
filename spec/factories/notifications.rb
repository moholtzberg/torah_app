FactoryGirl.define do
  factory :notification do
    message "MyText"
    association :user, factory: :user
    link "MyString"
    read_at Time.current

    factory :unread_notification do
      read_at nil
    end
  end
end
