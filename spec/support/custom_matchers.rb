require 'rspec/expectations'

RSpec::Matchers.define :respond_with_unauthenticated do
  match do |actual|
    p "No response provided" unless actual.response
    actual.response.status == 401 and
    actual.response.body == "{\"errors\":[\"You need to sign in or sign up before continuing.\"]}"
  end
end

RSpec::Matchers.define :respond_with_unauthorized do
  match do |actual|
    p "No response provided" unless actual.response
    actual.response.status == 401 and
    actual.response.body == "{\"errors\":{\"permissions\":\"You have no permissions\"}}"
  end
end
