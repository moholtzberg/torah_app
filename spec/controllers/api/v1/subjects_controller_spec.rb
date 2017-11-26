require 'rails_helper'

RSpec.describe Api::V1::SubjectsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:subj) { create(:subject) }
  let(:current_user) { create(:user) }

  describe "GET #index" do
    before do
      10.times { create(:subject) }
      get :index, params: { page: 1 }
    end

    it { is_expected.to respond_with :success }

    it "returns array of subjects" do
      expect(json_response).to eq(json_for(Subject.page(1)))
    end
  end

  describe "GET #show" do
    before do
      get :show, params: { id: subj.id }
    end

    it { is_expected.to respond_with :success }

    it "returns subject" do
      expect(json_response).to eq(json_for(subj))
      expect(json_response[:liked]).to be_falsey
    end

    context "when user liked subject" do
      it "returns subject" do
        api_sign_in current_user
        current_user.interests.create(subject_id: subj.id)
        get :show, params: { id: subj.id }

        expect(json_response[:headline]).to eq(subj.headline)
        expect(json_response[:liked]).to be_truthy
      end
    end
  end

  describe "POST #like" do
    context "when authenticated" do
      before do
        api_sign_in current_user
      end

      context "when user liked subject" do
        it "responds with :bad_request" do
          current_user.interests.create(subject_id: subj.id)
          post :like, params: { subject_id: subj.id }
          is_expected.to respond_with :bad_request
        end
      end

      context "when user doesn't liked subject" do
        it "responds with :success" do
          post :like, params: { subject_id: subj.id }
          is_expected.to respond_with :created
        end

        it "creates interest" do
          expect{post :like, params: { subject_id: subj.id }}
            .to change{Interest.count}.from(0).to(1)
        end
      end
    end

    context "when unauthenticated" do
      before do
        post :like, params: { subject_id: subj.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "DELETE #unlike" do
    context "when authenticated" do
      before do
        api_sign_in current_user
      end

      context "when user doesn't liked subject" do
        it "responds with :bad_request" do
          delete :unlike, params: { subject_id: subj.id }
          is_expected.to respond_with :bad_request
        end
      end

      context "when user liked subject" do
        before do
          current_user.interests.create(subject_id: subj.id)
        end

        it "responds with :success" do
          delete :unlike, params: { subject_id: subj.id }
          is_expected.to respond_with :no_content
        end

        it "destoys interest" do
          expect{delete :unlike, params: { subject_id: subj.id }}
            .to change{Interest.count}.from(1).to(0)
        end
      end
    end

    context "when unauthenticated" do
      before do
        delete :unlike, params: { subject_id: subj.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end
end
