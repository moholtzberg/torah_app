require 'rails_helper'

RSpec.describe Friendship, type: :model do
  subject { create(:friendship) }

  it { is_expected.to be_valid }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:friend).class_name("User") }
end
