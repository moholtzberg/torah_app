require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:current_user) { create(:user) }
  let(:subj) { create(:subject) }

  let(:chatroom) do
    chatroom = Chatroom.create
    chatroom.add_participant(user)
    chatroom.add_participant(current_user)
    chatroom
  end

  it { is_expected.to use_before_filter(:authenticate_user!) }

  describe "GET #favorites" do
    context 'when authenticated' do
      before do
        10.times { create(:interest, user: user) }
        sign_in current_user
        get :favorites, params: { user_id: user.id, page: 1 }
      end

      it { is_expected.to respond_with :success }
    end

    context 'when unauthenticated' do
      before do
        get :favorites, params: { user_id: user, page: 0 }
      end

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "GET #show" do
    context "when authorized" do
      before do
        sign_in current_user
        chatroom
        get :show, params: { id: user.id }
      end

      it { is_expected.to respond_with :success }

      it { is_expected.to render_template :show }

      it "assigns user" do
        expect(assigns(:user)).to eq(user)
      end

      it "assigns chatroom" do
        expect(assigns(:chatroom)).to eq(chatroom)
      end
    end

    context "when unauthorized" do
      before do
        get :show, params: { id: user.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end

    context "when requesting with invalid id" do
      before do
        sign_in current_user
        get :show, params: { id: "wrong id" }
      end

      it { is_expected.to respond_with :redirect }

      it { is_expected.to redirect_to users_url }

      it { is_expected.to set_flash }
    end
  end

  describe "POST #add_friend" do
    context "when authorized" do
      before do
        sign_in current_user
        post :add_friend, params: { id: user.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to user }

      it "creates friendship between users" do
        expect(current_user.friendships.find_by(friend_id: user.id)).to be_truthy
      end
    end

    context "when unauthorized" do
      before do
        post :add_friend, params: { id: user.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "DELETE #remove_friend" do
    context "when authorized" do
      before do
        sign_in current_user
        post :add_friend, params: { id: user.id }
        delete :remove_friend, params: { id: user.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to user }

      it "deletes friendship between users" do
        expect(current_user.friendships.find_by(friend_id: user.id)).to be_falsy
      end
    end

    context "when unauthorized" do
      before do
        delete :remove_friend, params: { id: user.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "GET #fetch_users" do
    before do
      10.times { create(:user) }
      sign_in current_user
      get :fetch_users, params: {
        search: { name: ""},
        filters: { online: "false", order_by: "newest" }
      }
    end

    it { is_expected.to respond_with :success }

    it { is_expected.to render_template(partial: "users/_user")}
  end

  describe "POST #add_subject" do
    context "when authorized" do
      before do
        sign_in current_user
      end

      context "when already liked subject" do
        before do
          post :add_subject, params: { id: subj.id }
          post :add_subject, params: { id: subj.id }
        end

        it { is_expected.to respond_with :bad_request }
      end

      context "when haven't liked subject yet" do
        before do
          post :add_subject, params: { id: subj.id }
        end

        it { is_expected.to respond_with :created }

        it "creates interest for current_user and subj" do
          expect(current_user.subjects).to eq([subj])
        end
      end
    end

    context "when unauthorized" do
      before do
        post :add_subject, params: { id: subj.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "DELETE #remove_subject" do
    context "when authorized" do
      before { sign_in current_user }

      context "when already liked subject" do
        before do
          post :add_subject, params: { id: subj.id }
          delete :remove_subject, params: { id: subj.id }
        end

        it { is_expected.to respond_with :no_content }

        it "deletes interest for current_user" do
          expect(current_user.subjects).to eq([])
        end
      end

      context "when haven't liked subject yet" do
        before do
          delete :remove_subject, params: { id: subj.id }
        end

        it { is_expected.to respond_with :bad_request }
      end
    end

    context "when unauthorized" do
      before do
        delete :remove_subject, params: { id: subj.id }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end
end
