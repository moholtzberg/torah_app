FactoryGirl.define do
  factory :user do
    name                { Faker::Name.name }
    sequence(:email)    { |n| "email#{n - 3}@gmail.com" }
    password            '111111'
    confirmed_at        Time.current
    status              'offline'
    country             { Faker::Address.country }
    state               { Faker::Address.state }
    city                { Faker::Address.city }
    moderator           false
    verified            false
    admin               false
    time_zone           'UTC'

    factory(:seed_user) do
      time_zone { Faker::Address.time_zone }
    end

    availability do
      a = []
      7.times do |i|
        range = Time.zone.parse('1996-01-01 00:00') + i.days..Time.zone.parse('1996-01-01 24:00') + i.days
        a << range
      end
      a
    end

    factory :admin do
      admin true
      name { 'Admin ' + Faker::Name.name }
      sequence(:email) { |n| "admin#{n}@gmail.com" }
    end

    factory :moderator do
      moderator true
    end

    factory :inviter_user do
      transient do
        user FactoryGirl.create(:user)
      end
      after(:create) { |u, e| FactoryGirl.create(:friendship, user: u, friend: e.user) }
    end

    factory :invited_user do
      transient do
        user FactoryGirl.create(:user)
      end
      after(:create) { |u, e| FactoryGirl.create(:friendship, user: e.user, friend: u) }
    end

    factory :friend do
      transient do
        user FactoryGirl.create(:user)
      end
      after(:create) do |u, e|
        FactoryGirl.create(:friendship, user: u, friend: e.user)
        FactoryGirl.create(:friendship, user: e.user, friend: u)
      end
    end

    factory :busy_user do
      name { 'Busy ' + Faker::Name.name }
      sequence(:email) { |n| "busy#{n}@gmail.com" }

      availability do
        a = []
        7.times do |i|
          range = Time.zone.parse('1996-01-01 12:00AM') + i.days..Time.zone.parse('1996-01-01 12:00AM') + i.days
          a << range
        end
        a
      end
    end

    factory :half_busy_user do
      availability do
        a = []
        7.times do |i|
          range = Time.zone.parse('1996-01-01 00:00') + i.days..Time.zone.parse('1996-01-01 11:00') + i.days
          a << range
        end
        a
      end
    end
  end
end
