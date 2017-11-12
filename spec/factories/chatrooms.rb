FactoryGirl.define do
  factory :chatroom do
    after(:create) do |chatroom|
      create(:participating, chatroom: chatroom)
      create(:participating, chatroom: chatroom)
    end
  end
end
