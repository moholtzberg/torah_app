require 'rails_helper'

RSpec.describe SubjectsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:subj) { create(:subject) }
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  it { is_expected.to use_before_filter(:authenticate_user!).except_on([:index, :show, :home, :fetch]) }

  context "when ActiveRecord::RecordNotFound is raised" do
    context "when authorized" do
      before do
        sign_in user
        get :show, params: { id: "not id" }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to subjects_url }

      it { is_expected.to set_flash }
    end
  end

  describe "GET #show" do
    before do
      sign_in user
      get :show, params: { id: subj.id }
    end

    it { is_expected.to respond_with :success }

    it { is_expected.to render_template :show }

    it "assigns subject" do
      expect(assigns(:subject)).to eq(subj)
    end
  end

  describe "GET #index" do
    before do
      10.times { create(:subject) }
      get :index
    end

    it { is_expected.to respond_with :success }

    it { is_expected.to render_template :index }
  end

  describe "GET #fetch" do
    before do
      10.times { create(:subject) }
      get :fetch
    end

    it { is_expected.to respond_with :success }

    it { is_expected.to render_template "subjects/_subject" }
  end

  describe "GET #edit" do
    context "when authorized" do
      context "when admin" do
        before do
          sign_in admin
          get :edit, params: { id: subj.id }
        end

        it { is_expected.to respond_with :success }

        it { is_expected.to render_template :edit }

        it "assigns subject" do
          expect(assigns(:subject)).to eq(subj)
        end
      end

      context "when not admin" do
        before do
          sign_in user
          get :edit, params: { id: subj.id }
        end

        it { is_expected.to set_flash }

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to subjects_url }
      end
    end

    context "when unathorized" do
      before do
        get :edit, params: { id: subj.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "GET #new" do
    context "when authorized" do
      context "when admin" do
        before do
          sign_in admin
          get :new, params: { id: subj.id }
        end

        it { is_expected.to respond_with :success }

        it { is_expected.to render_template :new }

        it "assigns subject" do
          expect(assigns(:subject)).to be_truthy
        end
      end

      context "when not admin" do
        before do
          sign_in user
          get :new, params: { id: subj.id }
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to subjects_url }

        it { is_expected.to set_flash }
      end
    end

    context "when unathorized" do
      before do
        get :new, params: { id: subj.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "POST #create" do
    context "when authorized" do
      context "when admin" do
        context "when requesting with valid data" do
          before do
            sign_in admin
            post :create, params: { subject: attributes_for(:subject) }
          end

          it "creates subject" do
            expect(Subject.count).to eq(1)
          end

          it { is_expected.to respond_with :found }

          it { is_expected.to redirect_to subject_url(Subject.first) }

          it { is_expected.to set_flash }
        end
      end

      context "when not admin" do
        before do
          sign_in user
          post :create, params: { subject: attributes_for(:subject) }
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to subjects_url }

        it { is_expected.to set_flash }
      end
    end

    context "when unathorized" do
      before do
        post :create, params: { subject: attributes_for(:subject) }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "PATCH #update" do
    context "when authorized" do
      context "when admin" do
        context "when requesting with valid data" do
          before do
            sign_in admin
            patch :update, params: { id: subj.id,
              subject: attributes_for(:subject, name: "new_name") }
          end

          it "updates subject" do
            expect(Subject.last.name).to eq("new_name")
          end

          it { is_expected.to respond_with :found }

          it { is_expected.to redirect_to subject_url(subj) }

          it { is_expected.to set_flash }
        end
      end

      context "when not admin" do
        before do
          sign_in user
          patch :update, params: { id: subj.id,
            subject: attributes_for(:subject, name: "new_name") }
        end

        it { is_expected.to set_flash }

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to subjects_url }
      end
    end

    context "when unathorized" do
      before do
        patch :update, params: { id: subj.id,
          subject: attributes_for(:subject, name: "new_name") }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "DELETE #destroy" do
    context "when authorized" do
      context "when admin" do
        before do
          sign_in admin
          delete :destroy, params: { id: subj.id }
        end

        it "deletes subject" do
          expect(Subject.count).to eq(0)
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to subjects_url }

        it { is_expected.to set_flash }
      end

      context "when not admin" do
        before do
          sign_in user
          delete :destroy, params: { id: subj.id }
        end

        it { is_expected.to respond_with :found }

        it { is_expected.to redirect_to subjects_url }

        it { is_expected.to set_flash }
      end
    end

    context "when unathorized" do
      before do
        delete :destroy, params: { id: subj.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end
end
