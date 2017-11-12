require 'rails_helper'

RSpec.describe Membership, type: :model do
  subject { build(:membership) }

  it { is_expected.to be_valid }

  it { is_expected.to define_enum_for(:role).with({ member: 0, moderator: 1, admin: 2 }) }

  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :organization }
end
