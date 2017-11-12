require 'rails_helper'

RSpec.describe Subject, type: :model do
  subject { create(:subject) }
  let(:child)  { create(:subject, parent: subject) }
  it { is_expected.to be_valid }

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :headline }
  it { is_expected.to respond_to :description }
  it { is_expected.to respond_to :featured }
  it { is_expected.to respond_to :banner }
  it { is_expected.to respond_to :thumbnail }
  it { is_expected.to respond_to :parent_id }

  it { is_expected.to belong_to(:parent).class_name("Subject") }
  it { is_expected.to have_many(:children).class_name("Subject").dependent(:destroy) }
  it { is_expected.to have_many(:interests).dependent(:destroy) }
  it { is_expected.to have_many(:lessons).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:interests) }

  it { is_expected.to validate_presence_of :name }

  it { is_expected.to validate_presence_of :description }

  it { is_expected.to validate_presence_of :headline }

  describe "check_if_parent_id_wont_loop validation" do
    context "when parent_id equals id " do
      it "returns errors" do
        subject.update_attributes(parent_id: subject.id)
        expect(subject.errors[:parent_id]).to include("You cannot inherit subject from himself")
      end
    end

    context "when parent_id equals children id " do
      it "returns errors" do
        subject.update_attributes(parent_id: child.id)
        expect(subject.errors[:parent_id]).to include("You cannot inherit subject from his child")
      end
    end
  end
end
