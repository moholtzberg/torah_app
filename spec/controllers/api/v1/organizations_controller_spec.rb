require 'rails_helper'

RSpec.describe Api::V1::OrganizationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:organization) { create(:confirmed_organization) }
  let(:organization_params) { attributes_for(:organization) }
  let(:invalid_organization_params) { attributes_for(:organization, name: nil) }
  let(:user) { create(:user) }

  describe "GET #index" do
    before do
      10.times { create(:confirmed_organization) }
      10.times { create(:organization) }
      get :index, params: { page: 1 }
    end

    it { is_expected.to respond_with :success }

    it "returns array of confirmed organizations" do
      expect(json_response).to eq(json_for(Organization.confirmed))
    end
  end

  describe "GET #show" do
    context "when requesting with valid id" do
      before do
        get :show, params: { id: organization.id }
      end

      it { is_expected.to respond_with :success }

      it "returns organization" do
        expect(json_response).to eq(json_for(organization, serializer: FullOraganizationSerializer))
      end
    end

    context "when requesting with invalid id" do
      before do
        get :show, params: { id: "not id" }
      end

      it { is_expected.to respond_with :bad_request }

      it "returns errors" do
        expect(json_response).to eq({ errors: { id: "Wrong organization id provided" }})
      end
    end
  end

  describe "POST #create" do
    context "when authenticated" do
      before do
        api_sign_in user
      end

      context "when requesting with valid data" do
        it "responds with :created" do
          post :create, params: { organization: organization_params }
          respond_with :created
        end

        it "creates organization" do
          expect{post :create, params: { organization: organization_params }}
            .to change{Organization.count}.from(0).to(1)
        end

        it "returns created organization" do
          post :create, params: { organization: organization_params }
          expect(json_response).to eq(json_for(Organization.last))
        end
      end

      context "when requesting with invalid data" do
        before do
          post :create, params: { organization: invalid_organization_params }
        end

        it { is_expected.to respond_with :unprocessable_entity }

        it "returns organization errors" do
          expect(json_response).to eq({ errors: { name: ["can't be blank"] }})
        end
      end
    end

    context "when unauthenticated" do
      before do
        post :create, params: { organization: organization_params }
      end
      
      it { is_expected.to respond_with_unauthenticated }
    end
  end
end
