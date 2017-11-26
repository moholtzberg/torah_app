require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:notification) { create(:notification, user: user) }

  describe "GET #index" do
    before do
      10.times { create(:notification, user: user) }
    end

    context "when authenticated" do
      before do
        api_sign_in user
      end

      context "when requesting with limit param" do
        before do
          get :index, params: { limit: 5 }
        end

        it { is_expected.to respond_with :success }

        it "returns limited array of notifications" do
          expect(json_response).to eq(json_for(Notification.order("created_at DESC").limit(5)))
        end
      end

      context "when requesting without limit param" do
        before do
          get :index, params: { page: 1 }
        end

        it { is_expected.to respond_with :success }

        it "returns array of notifications" do
          expect(json_response).to eq(json_for(Notification.order("created_at DESC").page(1)))
        end
      end
    end

    context "when unauthenticated" do
      before do
        get :index, params: { page: 1 }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      before do
        api_sign_in user
      end

      it "responds with :no_content" do
        delete :destroy, params: { id: notification.id }
        is_expected.to respond_with :no_content
      end

      it "deletes notification" do
        notification
        expect{delete :destroy, params: { id: notification.id }}
          .to change{user.notifications.count}.from(1).to(0)
      end

      context "when wrong notification id provided" do
        before do
          delete :destroy, params: { id: "not id" }
        end

        it { is_expected.to respond_with :bad_request }

        it "return errors" do
          expect(json_response).to eq({ errors: { id: "Wrong notification id provided" }})
        end
      end
    end

    context "when unauthenticated" do
      before do
        delete :destroy, params: { id: notification.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "PATCH #mark_as_read" do
    context "when authenticated" do
      before do
        api_sign_in user
        10.times { create(:unread_notification, user: user) }
      end

      it "responds with :success" do
        patch :mark_as_read
        is_expected.to respond_with :success
      end

      it "set notification read_at" do
        expect{patch :mark_as_read}
          .to change{user.notifications.unread.count}.from(10).to(0)
      end
    end

    context "when unauthenticated" do
      before do
        patch :mark_as_read
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end
end
