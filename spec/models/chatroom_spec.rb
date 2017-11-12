require 'rails_helper'

RSpec.describe Chatroom, type: :model do
  subject { create(:chatroom) }

  let(:user) { create(:user) }
  let(:participants) { subject.users }

  it { is_expected.to be_valid }

  it { is_expected.to have_many(:participatings).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:participatings) }
  it { is_expected.to have_many(:messages).dependent(:destroy) }

  it "create participating with user on add_participant" do
    expect{subject.add_participant(user)}
      .to change{subject.users.count}.from(2).to(3)
  end

  it "returns string with names of other users participants_name_without" do
    expect(subject.participants_name_without(participants.first))
      .to eql(participants.last.name + " ")
  end

  it "returns chatroom on find_by_participants" do
    expect(Chatroom.find_by_participants(participants.first, participants.last))
      .to eql(subject)
  end
end
