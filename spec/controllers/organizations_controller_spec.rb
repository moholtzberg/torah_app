require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:organization_params) { attributes_for(:organization) }
  let(:wrong_organization_params) do
    attributes_for(:organization, name: "", headline: "", founder: user)
  end

  describe "GET #new" do
    context "when authorized" do
      before do
        sign_in user
        get :new
      end

      it { is_expected.to respond_with :success }

      it { is_expected.to render_template :new }

      it "assigns organization" do
        expect(assigns[:organization].attributes).to eq(Organization.new.attributes)
      end
    end

    context "when unauthorized" do
      before do
        get :new
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end

  describe "POST #create" do
    context "when authorized" do
      before do
        sign_in user
      end

      context "when requesting with valid data" do
        before do
          post :create, params: { organization: organization_params }
        end

        it { is_expected.to redirect_to organizations_url }

        it "creates new organization" do
          expect(Organization.last.founder).to eq(user)
          expect(Organization.last.confirmed_at).to be_falsy
          expect(user.organizations.last).to eq(Organization.last)
        end

        it "permits params" do
          is_expected.to permit(:name, :headline, :description, :banner, :thumbnail,
             :thumbnail_cache, :remove_thumbnail, :banner_cache, :remove_banner)
            .for(:create, verb: :post, params: { organization: organization_params })
            .on(:organization)
        end
      end

      context "when requesting with invalid data" do
        before do
          post :create, params: { organization: wrong_organization_params }
        end

        it { is_expected.to respond_with :unprocessable_entity }

        it { is_expected.to render_template :new }

        it "assigns organization" do
          expect(assigns[:organization].attributes).to eq(
            user.foundations.build(wrong_organization_params).attributes
          )
        end

        it "add errors to organization" do
          expect(assigns[:organization].errors[:name]).to include("can't be blank")
          expect(assigns[:organization].errors[:headline]).to include("can't be blank")
        end
      end
    end

    context "when unauthorized" do
      before do
        post :create, params: { organization: organization_params }
      end

      it { is_expected.to respond_with :found }

      it { is_expected.to redirect_to new_user_session_url }
    end
  end
end
