require 'rails_helper'

RSpec.describe Post, type: :model do
  subject { create(:post) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:organization) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:body) }
end
