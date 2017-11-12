require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  let(:invited_user) { create(:invited_user, user: subject) }
  let(:friend) { create(:friend, user: subject) }
  let(:not_friend) { create(:user) }
  let(:inviter_user) { create(:inviter_user, user: subject) }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :email }
  it { is_expected.to respond_to :availability }
  it { is_expected.to respond_to :admin }
  it { is_expected.to respond_to :country }
  it { is_expected.to respond_to :city }
  it { is_expected.to respond_to :state }
  it { is_expected.to respond_to :moderator }
  it { is_expected.to respond_to :verified }
  it { is_expected.to respond_to :time_zone }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_least(5).is_at_most(40) }

  it { is_expected.to have_many(:interests).dependent(:destroy) }
  it { is_expected.to have_many(:participatings).dependent(:destroy) }
  it { is_expected.to have_many(:subjects).through(:interests) }
  it { is_expected.to have_many(:chatrooms).through(:participatings) }
  it { is_expected.to have_many(:messages) }
  it { is_expected.to have_many(:friendships).dependent(:destroy) }
  it { is_expected.to have_many(:friends).through(:friendships) }
  it { is_expected.to have_many(:lessons).dependent(:destroy) }
  it { is_expected.to have_many(:organizations).through(:memberships) }
  it { is_expected.to have_many(:foundations).class_name('Organization') }
  it { is_expected.to have_many(:posts) }
  it { is_expected.to have_many(:notifications).dependent(:destroy) }

  it { is_expected.to define_enum_for(:status).with(offline: 0, online: 1, away: 2) }

  describe 'order_by scope' do
    it 'returns newest users on newest' do
      2.times { create(:user) }
      expect(User.order_by('newest').first).to eq(User.last)
    end

    it 'return oldest users on oldest' do
      2.times { create(:user) }
      expect(User.order_by('oldest').first).to eq(User.first)
    end
  end

  describe '#appear' do
    it 'changes status to online' do
      expect { subject.appear }.to change { subject.status }.from('offline').to('online')
    end
  end

  describe '#disappear' do
    it 'changes status to offline' do
      subject.status = 'online'
      expect { subject.disappear }.to change { subject.status }.from('online').to('offline')
    end
  end

  describe '#away' do
    it 'changes status to away on away' do
      expect { subject.away }.to change { subject.status }.from('offline').to('away')
    end
  end

  describe '#relation_with' do
    context 'when you invited user' do
      it 'returns invited_user' do
        expect(subject.relation_with(invited_user)).to eql('invited_user')
      end
    end

    context 'when you invited by user' do
      it 'returns invited_user' do
        expect(subject.relation_with(inviter_user)).to eql('invited_by_user')
      end
    end

    context 'when you are friends' do
      it 'returns friend' do
        expect(subject.relation_with(friend)).to eql('friends')
      end
    end

    context "when you aren't friends" do
      it 'returns not_friend' do
        expect(subject.relation_with(not_friend)).to eql('not_friends')
      end
    end
  end

  describe 'availability_should_be_inside_availability_range validation' do
    context 'when availability is valid' do
      it { is_expected.to be_valid }
    end

    context 'when availability is invalid' do
      context 'when availability is more right than availability range' do
        before do
          subject.availability = [Time.zone.parse('1996-01-08 00:00')..Time.zone.parse('1996-01-09 10:00')]
          subject.save
        end

        it { is_expected.to be_invalid }

        it 'adds error' do
          expect(subject.errors[:availability]).to include('Invalid availability ranges are provided')
        end
      end

      context 'when availability is more left than availability range' do
        before do
          subject.availability = [Time.zone.parse('1995-12-31 10:00')..Time.zone.parse('1996-01-01 10:00')]
          subject.save
        end

        it { is_expected.to be_invalid }

        it 'adds error' do
          expect(subject.errors[:availability]).to include('Invalid availability ranges are provided')
        end
      end
    end
  end
end
