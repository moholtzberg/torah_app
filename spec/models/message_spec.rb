require 'rails_helper'

RSpec.describe Message, type: :model do
  subject { build(:message) }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:body) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:chatroom) }
  it { is_expected.to have_many(:users) }

  it { is_expected.to validate_length_of(:body).is_at_least(1).is_at_most(200) }
  it { is_expected.to validate_presence_of(:body) }

  it "runs MessageBroadcastJob on after_commit" do
    expect { subject.save }.to have_enqueued_job(MessageBroadcastJob).exactly(:once)
  end
end
