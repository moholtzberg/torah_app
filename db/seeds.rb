require 'database_cleaner'
require 'factory_girl_rails'


DatabaseCleaner.clean_with(:truncation, { except: %[subjects] })

5.times do |n|
  FactoryGirl.create(:seed_user)
end

5.times do |n|
  FactoryGirl.create(:busy_user)
end

FactoryGirl.create(:admin)

10.times do |n|
  FactoryGirl.create(:confirmed_organization, founder_id: n + 1)
end

Organization.all.each do |organization|
  10.times do |n|
    FactoryGirl.create(:post, organization: organization, user: organization.founder)
  end
end

if Subject.count < 1
  3.times do |n|
    subject = Subject.create!(name: "Subject#{n}", headline: "headline", description: "description")
    3.times do |k|
      children  = subject.children.create!(name: "Subject#{n} #{k}", headline: "headline", description: "description")
      3.times do |m|
        children.children.create!(name: "Subject#{n} #{k} #{m}", headline: "headline", description: "description")
      end
    end
  end
end
