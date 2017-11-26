require 'rails_helper'

RSpec.describe Api::V1::LessonsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:busy_user) { create(:busy_user) }

  let(:invalid_lesson_params) do
    attributes_for(:lesson,
      receiver_id: busy_user.id,
      subject_id: create(:subject).id)
  end

  let(:lesson_params) do
    attributes_for(:lesson,
      receiver_id: create(:user).id,
      subject_id: create(:subject).id)
  end

  describe 'GET #index' do
    context 'when authenticated' do
      before do
        api_sign_in user
        10.times { create(:lesson, sender: user) }
        get :index, params: { page: 1 }
      end

      it { is_expected.to respond_with :success }

      it 'returns array of lessons' do
        expect(json_response).to eq(json_for(user.lessons.page(1)))
      end
    end

    context 'when unauthenticated' do
      before do
        get :index, params: { page: 1 }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "GET #subjects" do
    context "when authenticated" do
      before do
        api_sign_in user
        5.times { create(:subject, name: "naruto") }
        5.times { create(:subject, name: "sasuke") }
        get :subjects, params: { name: "sas"}
      end

      it { is_expected.to respond_with :success }

      it "returns array of subjects" do
        expect(json_response).to eq(json_for(Subject.where(name: "sasuke")))
      end
    end

    context 'when unauthenticated' do
      before do
        get :subjects, params: { name: "test" }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "POST #create" do
    context "when authenticated" do
      before do
        api_sign_in user
      end

      context "when requesting with valid data" do
        it "responds with :created" do
          post :create, params: { lesson: lesson_params }
          is_expected.to respond_with :created
        end

        it "creates new lesson" do
          expect{post :create, params: { lesson: lesson_params }}
            .to change{Lesson.count}.from(0).to(1)
        end
      end

      context "when requesting with invalid data" do
        before do
          post :create, params: { lesson: invalid_lesson_params }
        end

        it { is_expected.to respond_with :unprocessable_entity }

        it "returs errors" do
          expect(json_response)
            .to eq({ errors: { time: ["#{busy_user.name} is not available at that time"] }})
        end
      end
    end

    context 'when unauthenticated' do
      before do
        post :create, params: { lesson: lesson_params }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "PATCH #update" do
    context "when authenticated" do
      before do
        api_sign_in user
      end

      context "when current user is sender" do
        before do
          create(:unconfirmed_lesson, sender: user)
          patch :update, params: { id: Lesson.last.id, lesson: lesson_params }
        end

        it { is_expected.to respond_with :bad_request }

        it "returns errors" do
          expect(json_response).to eq({ errors: { receiver: "You are not receiver"}})
        end
      end

      context "when current user is receiver" do
        before do
          create(:unconfirmed_lesson, receiver: user)
        end

        it "responds with :success" do
          patch :update, params: { id: Lesson.last.id, lesson: lesson_params }
          is_expected.to respond_with :success
        end

        it "confirmes lesson" do
          expect{patch :update, params: { id: Lesson.last.id, lesson: lesson_params }}
            .to change{Lesson.last.confirmed_at}.from(nil)
        end
      end
    end

    context 'when unauthenticated' do
      before do
        patch :update, params: { id: "id", lesson: lesson_params }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      before do
        api_sign_in user
        create(:unconfirmed_lesson, receiver: user)
      end

      it "responds with :no_content" do
        delete :destroy, params: { id: Lesson.last.id }
        is_expected.to respond_with :no_content
      end

      it "destroys lesson" do
        expect{delete :destroy, params: { id: Lesson.last.id }}
          .to change{Lesson.count}.from(1).to(0)
      end
    end

    context 'when unauthenticated' do
      before do
        delete :destroy, params: { id: "id" }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end
end
