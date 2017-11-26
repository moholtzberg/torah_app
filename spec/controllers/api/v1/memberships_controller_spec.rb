require 'rails_helper'

RSpec.describe Api::V1::MembershipsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  let(:member) do
    u = create(:user)
    create(:confirmed_membership, user: u, organization: organization)
    u
  end

  let(:admin) do
    u = create(:user)
    create(:confirmed_membership, user: u, organization: organization, role: "admin")
    u
  end

  describe "POST #send_invite" do
    context "when authenticated" do
      before do
        api_sign_in user
      end

      context "when membership is not present" do
        it "responds with :created" do
          post :send_invite, params: { organization_id: organization.id }
          is_expected.to respond_with :created
        end

        it "creates membership" do
          expect{post :send_invite, params: { organization_id: organization.id }}
            .to change{user.memberships.count}.from(0).to(1)
        end
      end

      context "when membership is present" do
        before do
          post :send_invite, params: { organization_id: organization.id }
          post :send_invite, params: { organization_id: organization.id }
        end

        it { is_expected.to respond_with :bad_request }

        it "returns errors" do
          expect(json_response).to eq({ errors: { id: "You've already sent invite"}})
        end
      end
    end

    context "when unauthenticated" do
      before do
        post :send_invite, params: { organization_id: organization.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "DELETE #cancel_invite" do
    context "when authenticated" do
      before do
        api_sign_in user
      end

      context "when membership is present" do
        before do
          create(:membership, organization: organization, user: user)
        end
        it "responds with :no_content" do
          delete :cancel_invite, params: { organization_id: organization.id }
          is_expected.to respond_with :no_content
        end

        it "creates membership" do
          expect{delete :cancel_invite, params: { organization_id: organization.id }}
            .to change{user.memberships.count}.from(1).to(0)
        end
      end

      context "when membership is not present" do
        before do
          delete :cancel_invite, params: { organization_id: organization.id }
        end

        it { is_expected.to respond_with :bad_request }

        it "returns errors" do
          expect(json_response).to eq({ errors: { id: "You don't have send invite yet"}})
        end
      end
    end

    context "when unauthenticated" do
      before do
        delete :cancel_invite, params: { organization_id: organization.id }
      end

      it { is_expected.to respond_with_unauthenticated }
    end
  end

  describe "PATCH #accept_invite" do
    context "when authorizated" do
      before do
        api_sign_in organization.founder
        create(:membership, organization: organization, user: user)
      end

      it "responds with :success" do
        patch :accept_invite, params: {  organization_id: organization.id, user_id: user.id }
        is_expected.to respond_with :success
      end

      it "sets membership's confirmed_at attribute" do
        expect{patch :accept_invite, params: {  organization_id: organization.id, user_id: user.id }}
          .to change{Membership.last.confirmed_at}.from(nil)
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in user
        patch :accept_invite, params: {  organization_id: organization.id, user_id: user.id }
      end

      it { is_expected.to respond_with :unauthorized }

      it "returns errors" do
        expect(json_response).to eq({ errors: { permissions: "You have no permissions" }})
      end
    end
  end

  describe "GET #members" do
    before do
      10.times { create(:confirmed_membership, organization: organization) }
    end

    context "when authorized" do
      before do
        api_sign_in member
        get :members, params: { organization_id: organization.id, page: 1 }
      end

      it { is_expected.to respond_with :success }

      it "returns array of members" do
        expect(json_response).to eq(json_for(organization.members.page(1)))
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in user
        get :members, params: { organization_id: organization.id, page: 1 }
      end

      it { is_expected.to respond_with :unauthorized }

      it "returns errors" do
        expect(json_response).to eq({ errors: { permissions: "You have no permissions" }})
      end
    end
  end

  describe "GET #candidates" do
    before do
      10.times { create(:membership, organization: organization) }
    end

    context "when authorized" do
      before do
        api_sign_in admin
        get :candidates, params: { organization_id: organization.id, page: 1 }
      end

      it { is_expected.to respond_with :success }

      it "returns array of candidates" do
        expect(json_response).to eq(json_for(organization.candidates.page(1)))
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in member
        get :candidates, params: { organization_id: organization.id, page: 1 }
      end

      it { is_expected.to respond_with :unauthorized }

      it "returns errors" do
        expect(json_response).to eq({ errors: { permissions: "You have no permissions" }})
      end
    end
  end

  describe "PATCH #change_role" do
    context "when authorized" do
      before do
        api_sign_in organization.founder
      end

      it "responds with :success" do
        patch :change_role, params: { organization_id: organization.id, user_id: admin.id, role: "member" }
        is_expected.to respond_with :success
      end

      it "changes user role" do
        expect{patch :change_role, params: { organization_id: organization.id, user_id: admin.id, role: "member" }}
          .to change{admin.memberships.find_by(organization_id: organization).role}.from("admin").to("member")
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in admin
        patch :change_role, params: {organization_id: organization.id, user_id: admin.id, role: "member" }
      end

      it { is_expected.to respond_with :unauthorized }

      it "returns errors" do
        expect(json_response).to eq({ errors: { permissions: "You have no permissions" }})
      end
    end
  end
end
