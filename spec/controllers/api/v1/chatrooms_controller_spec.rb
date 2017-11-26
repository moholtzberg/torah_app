require 'rails_helper'

RSpec.describe Api::V1::ChatroomsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:chatroom) { create_chatroom_for(user, create(:user)) }

  describe "GET #index" do
    context "when authenticated" do
      before do
        api_sign_in user
        10.times { create_chatroom_for(user, create(:user)) }
        get :index, params: { page: 1 }
      end

      it { is_expected.to respond_with :success }

      it "returns array of chatrooms" do
        expect(json_response).to eq(json_for(Chatroom.page(1)))
      end
    end

    context "when unauthenticated" do
      before do
        get :index, params: { page: 1 }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "GET #show" do
    context "when authorized" do
      before do
        api_sign_in user
        get :show, params: { id: create_chatroom_for(user, create(:user)).id }
      end

      it { is_expected.to respond_with :success }

      it "returns chatroom" do
        expect(json_response).to eq(json_for(Chatroom.last))
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in create(:user)
        get :show, params: { id: create(:chatroom).id }
      end

      it { is_expected.to respond_with_unauthorized }
    end
  end

  describe "GET #messages" do
    context "when authorized" do
      before do
        api_sign_in user
        create_chatroom_for(user,create(:user))
        10.times { create(:message, chatroom: Chatroom.last, user: user) }
        get :messages, params: { chatroom_id: Chatroom.last.id, page: 1 }
      end

      it { is_expected.to respond_with :success }

      it "returns array of messages" do
        expect(json_response).to eq(json_for(Message.all.page(1)))
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in user
        get :messages, params: { chatroom_id: create(:chatroom).id }
      end

      it { is_expected.to respond_with_unauthorized }
    end
  end

  describe "POST #create" do
    context "when authenticated" do
      before do
        api_sign_in user
      end

      it "responds with :created" do
        post :create, params: { user_id: create(:user).id }
        is_expected.to respond_with :created
      end

      it "creates new chatroom" do
        expect{post :create, params: { user_id: create(:user).id }}
          .to change{Chatroom.count}.from(0).to(1)
      end

      it "creates new participatings" do
        expect{post :create, params: { user_id: create(:user).id }}
          .to change{Participating.count}.from(0).to(2)
      end
    end

    context "when unauthenticated" do
      before do
        post :create, params: { user_id: create(:user).id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "POST #add_participant" do
    context "when authorized" do
      before do
        api_sign_in user
        create_chatroom_for(user, create(:user))
      end

      it "responds with :created" do
        post :add_participant, params: { chatroom_id: Chatroom.last.id, user_id: create(:user).id }
        is_expected.to respond_with :created
      end

      it "creates new participating" do
        expect{post :add_participant, params: { chatroom_id: Chatroom.last.id, user_id: create(:user).id }}
          .to change{Participating.count}.from(2).to(3)
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in user
        post :add_participant, params: { chatroom_id: create(:chatroom).id, user_id: create(:user).id }
      end

      it { is_expected.to respond_with_unauthorized }
    end
  end
end
