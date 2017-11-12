require 'rails_helper'

RSpec.describe LessonsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:current_user) { create(:user) }
  let(:user) { create(:user) }
  let(:busy_user) { create(:busy_user) }
  let(:lesson) { create(:lesson, receiver: current_user, sender: user) }
  let(:subj) { create(:subject) }


  describe "GET #index" do
    context "when authorized" do
      before do
        sign_in current_user
        get :index, params: { user_id: current_user.id }
      end

      it { is_expected.to respond_with :success }

      it { is_expected.to render_template :index }
    end

    context "when unauthorized" do
      before do
        get :index, params: { user_id: "not current_user" }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "GET #fetch_lessons" do
    context "when authorized" do
      before do
        sign_in current_user
        5.times { create(:lesson, receiver: user, sender: current_user, confirmed_at: nil) }
        get :fetch_lessons
      end

      it { is_expected.to respond_with :success }

      it { is_expected.to render_template(partial: "lessons/_lesson") }
    end

    context "when unauthorized" do
      before do
        get :fetch_lessons
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "POST #create" do
   context "when authorized" do
     before do
       sign_in current_user
     end

     context "when requesting with valid data" do
       before do
         post :create, params: { user_id: user.id,
           lesson: attributes_for(:lesson,
             sender_id: current_user.id,
             receiver_id: user.id,
             subject_id: subj.id)
         }
       end

       it { is_expected.to redirect_to user_url(user) }

       it "creates lesson" do
         expect(current_user.lessons.count).to eql(1)
       end
     end

     context "when requesting with invalid data" do
       before do
         post :create, params: { user_id: user.id,
           lesson: attributes_for(:lesson,
             sender_id: current_user.id,
             receiver_id: user.id,
             subject_id: subj.id)
         }
       end

       it { is_expected.to redirect_to user_url(user) }

       it "creates lesson" do
         expect(current_user.lessons.count).to eql(1)
       end
     end
   end

   context "when unauthorized" do
     before do
       get :new, params: { user_id: user.id }
     end

     it { is_expected.to respond_with :found }

     it { is_expected.to redirect_to new_user_session_url }
   end
  end

  describe "GET #new" do
    context "when authorized" do
      before do
        sign_in current_user
        get :new, params: { user_id: user.id }
      end

      it { is_expected.to respond_with :success }

      it { is_expected.to render_template :new }

      it "asigns user" do
        expect(assigns(:user)).to eq(user)
      end

      it "asigns lesson" do
        expect(assigns(:lesson)).not_to be_falsy
      end
    end

    context "when unauthorized" do
      before do
        get :new, params: { user_id: user.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "POST #accept_invite" do
    context "when authorized" do
      context "when accept lesson on witch you have been invited" do
        before do
          sign_in current_user
          post :accept_invite, params: { id: lesson.id }
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to user_lessons_url(current_user) }

        it "sets confirmed_at of lesson" do
          expect(current_user.lessons.last.confirmed_at).not_to be_falsy
        end
      end

      context "when accept lesson on witch you haven`t been invited" do
        before do
          sign_in user
          post :accept_invite, params: { id: lesson.id }
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to user_lessons_url(user) }

        it { is_expected.to set_flash }
      end
    end

    context "when unauthorized" do
      before do
        post :accept_invite, params: { id: lesson.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "DELETE #decline_invite" do
    context "when authorized" do
      context "when declines your lesson" do
        before do
          sign_in current_user
          post :decline_invite, params: { id: lesson.id }
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to user_lessons_url(current_user) }

        it "deletes lesson" do
          expect(current_user.lessons.count).to eq(0)
        end
      end

      context "when declines not your lessons" do
        before do
          sign_in create(:user)
          delete :decline_invite, params: { id: lesson.id }
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to user_lessons_url(User.first) }

        it { is_expected.to set_flash }
      end
    end

    context "when unauthorized" do
      before do
        delete :decline_invite, params: { id: lesson.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "GET #fetch_subjects" do
    before do
      sign_in current_user
    end

    context "when requesting with valid subject name" do
      before do
        2.times  { create(:subject, name: "pattern") }
        get :fetch_lessons, params: { search: "patt" }
      end

      it { is_expected.to respond_with :success }
    end

    context "when requesting with invalid subject name" do
      before do
        2.times  { create(:subject) }
        get :fetch_lessons, params: { search: "pattern" }
      end

      it { is_expected.to respond_with :success }
    end
  end
end
