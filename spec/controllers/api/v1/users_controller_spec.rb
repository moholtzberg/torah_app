require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:current_user) { create(:user) }

  describe "GET #favorites" do
    context 'when authenticated' do
      before do
        10.times { create(:interest, user: user) }
        api_sign_in current_user
        get :favorites, params: { user_id: user.id, page: 1 }
      end

      it { is_expected.to respond_with :success }

      it "returns array of favorited subjects" do
        expect(json_response).to eq(json_for(Subject.page(1)))
      end
    end

    context 'when unauthenticated' do
      before do
        get :favorites, params: { user_id: user, page: 0 }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe 'GET #index' do
    before do
      10.times { create(:user) }
    end

    context 'when authenticated' do
      before do
        api_sign_in current_user
        get :index, params: { page: 1 }
      end

      it { is_expected.to respond_with :success }

      it 'returns array of users' do
        expect(json_response).to eq(json_for(User.page(1)))
      end
    end

    context 'when unauthenticated' do
      before do
        get :index, params: { page: 0 }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "GET #show" do
    context "when authenticated" do
      before do
        create_chatroom_for(current_user, user)
        create_memberships_for(user)
        api_sign_in current_user
        get :show, params: { id: user.id }
      end

      it { is_expected.to respond_with :success }

      it "returns user" do
        expect(json_response[:chatroom]).to eq(json_for(Chatroom.first))
        expect(json_response[:organizations]).to eq(json_for(Organization.all))
        expect(json_response[:name]).to eq(user.name)
      end
    end

    context "when unauthenticated" do
      before do
        get :show, params: { id: user.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "POST #add_to_friends" do
    context "when authenticated" do
      before do
        api_sign_in current_user
      end

      it "creates friendship" do
          expect{post :add_to_friends, params: { user_id: user.id }}
          .to change{Friendship.count}.from(0).to(1)
      end

      it "responds with :created" do
        post :add_to_friends, params: { user_id: user.id }
        is_expected.to respond_with :created
      end
    end

    context "when unauthenticated" do
      before do
        post :add_to_friends, params: { user_id: user.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "DELETE #remove_from_friends" do
    context "when authenticated" do
      before do
        api_sign_in current_user
        post :add_to_friends, params: { user_id: user.id }
      end

      it "destoys friendship" do
          expect{delete :remove_from_friends, params: { user_id: user.id }}
          .to change{Friendship.count}.from(1).to(0)
      end

      it "responds with :no_content" do
        post :remove_from_friends, params: { user_id: user.id }
        is_expected.to respond_with :no_content
      end
    end

    context "when unauthenticated" do
      before do
        post :remove_from_friends, params: { user_id: user.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end
end
