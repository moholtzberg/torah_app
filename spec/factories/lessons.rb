FactoryGirl.define do
  factory :lesson do
    message "MyText"
    association :sender, factory: :user
    association :receiver, factory: :user
    association :subject, factory: :subject
    confirmed_at Time.current
    starts_at_time "10:00"
    starts_at_date  Date.tomorrow
    ends_at_time "12:00"
    ends_at_date Date.tomorrow
    recurring false

    factory :reccuring_lesson do
      starts_at_date  Date.tomorrow + 7.days
      ends_at_date Date.tomorrow + 7.days
      recurring true
    end
  end
end
