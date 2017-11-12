require 'rails_helper'

RSpec.describe Lesson, type: :model do
  subject { build(:lesson) }


  it { is_expected.to be_valid }

  it { is_expected.to respond_to :message }
  it { is_expected.to respond_to :time }
  it { is_expected.to respond_to :sender_id }
  it { is_expected.to respond_to :receiver_id }
  it { is_expected.to respond_to :subject_id }
  it { is_expected.to respond_to :confirmed_at }
  it { is_expected.to respond_to :recurring }

  describe ".sender_should_be_available_on_lesson_time" do
    context "when sender is available on lesson time" do
      it { is_expected.to be_valid }
    end

    context "when sender is unavailable on lesson time" do
      context "when lesson time range overlaps with one of availability ranges" do
        before do
           subject.sender = create(:half_busy_user)
           subject.save
         end

        it { is_expected.to be_invalid }

        it "add error to subject" do
          expect(subject.errors[:time]).to include(
            "#{subject.sender.name} is not available at that time")
        end
      end

      context "when lesson time range doesn't overlaps with one of availability ranges" do
        before do
           subject.sender = create(:busy_user)
           subject.save
         end

        it { is_expected.to be_invalid }

        it "add error to subject" do
          expect(subject.errors[:time]).to include(
            "#{subject.sender.name} is not available at that time")
        end
      end
    end
  end

  describe ".receiver_should_be_available_on_lesson_time" do
    context "when receiver is available on lesson time" do
      it { is_expected.to be_valid }
    end

    context "when receiver is unavailable on lesson time" do
      context "when lesson time range overlaps with one of availability ranges" do
        before do
           subject.receiver = create(:half_busy_user)
           subject.save
         end

        it { is_expected.to be_invalid }

        it "add error to subject" do
          expect(subject.errors[:time]).to include(
            "#{subject.receiver.name} is not available at that time")
        end
      end

      context "when lesson time range doesn't overlaps with one of availability ranges" do
        before do
           subject.receiver = create(:busy_user)
           subject.save
         end

        it { is_expected.to be_invalid }

        it "add error to subject" do
          expect(subject.errors[:time]).to include(
            "#{subject.receiver.name} is not available at that time")
        end
      end
    end
  end

  describe ".receiver_cannot_be_busy_on_lesson_time" do
    context "when receiver doesn't have lessons on subject's time" do
      it { is_expected.to be_valid }
    end

    context "when receiver already has lessons on subject's time" do
      context "when other lesson is not reccuring" do
        context "when subjects time is inside other lesson's time range" do
          before do
             create(:lesson, receiver: subject.receiver)
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.receiver.name} is busy at that time")
          end
        end

        context "when subjects time overlaps with other lesson's time range" do
          before do
             create(:lesson, receiver: subject.receiver, starts_at_time: "9:00", ends_at_time: "13:00")
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.receiver.name} is busy at that time")
          end
        end
      end

      context "when other lesson is reccuring" do
        context "when subjects time is inside other lesson's time range" do
          before do
             create(:reccuring_lesson, receiver: subject.receiver)
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.receiver.name} is busy at that time")
          end
        end

        context "when subjects time overlaps with other lesson's time range" do
          before do
             create(:reccuring_lesson, receiver: subject.receiver, starts_at_time: "9:00", ends_at_time: "13:00")
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.receiver.name} is busy at that time")
          end
        end
      end
    end
  end

  describe ".sender_cannot_be_busy_on_lesson_time" do
    context "when sender doesn't have lessons on subject's time" do
      it { is_expected.to be_valid }
    end

    context "when sender already has lessons on subject's time" do
      context "when other lesson is not reccuring" do
        context "when subjects time is inside other lesson's time range" do
          before do
             create(:lesson, sender: subject.sender)
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.sender.name} is busy at that time")
          end
        end

        context "when subjects time overlaps with other lesson's time range" do
          before do
             create(:lesson, sender: subject.sender, starts_at_time: "9:00", ends_at_time: "13:00")
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.sender.name} is busy at that time")
          end
        end
      end

      context "when other lesson is reccuring" do
        context "when subjects time is inside other lesson's time range" do
          before do
             create(:reccuring_lesson, sender: subject.sender)
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.sender.name} is busy at that time")
          end
        end

        context "when subjects time overlaps with other lesson's time range" do
          before do
             create(:reccuring_lesson, sender: subject.sender, starts_at_time: "9:00", ends_at_time: "13:00")
             subject.save
           end

          it { is_expected.to be_invalid }

          it "add error to subject" do
            expect(subject.errors[:time]).to include(
              "#{subject.sender.name} is busy at that time")
          end
        end
      end
    end
  end
end
