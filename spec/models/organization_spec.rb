require 'rails_helper'

RSpec.describe Organization, type: :model do
  subject { build(:organization) }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:headline) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:confirmed_at) }
  it { is_expected.to respond_to(:banner) }
  it { is_expected.to respond_to(:thumbnail) }
  it { is_expected.to respond_to(:founder_id) }

  it { is_expected.to belong_to(:founder).class_name("User") }
  it { is_expected.to have_many(:memberships).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:memberships) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_presence_of :headline }

  it { is_expected.to validate_uniqueness_of(:name) }
end
