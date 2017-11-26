require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:organization) { create(:confirmed_organization) }
  let(:org_post) { create(:post, organization: organization) }
  let(:post_params) { attributes_for(:post, title: "new title") }
  let(:invalid_post_params) { attributes_for(:post, title: nil) }

  describe "GET #index" do
    before do
      10.times do
        create(:post, organization: organization, user: organization.founder)
      end
      get :index, params: { organization_id: organization.id, page: 1 }
    end

    it { is_expected.to respond_with :success }

    it "returns array of posts" do
      expect(json_response)
        .to eq(json_for(organization.posts.order("created_at DESC").page(1)))
    end
  end

  describe "GET #show" do
    before do
      get :show, params: { organization_id: organization.id, id: org_post.id }
    end

    it { is_expected.to respond_with :success }

    it "returns post" do
      expect(json_response).to eq(json_for(org_post))
    end
  end

  describe "POST #create" do
    context "when authorizated" do
      before do
        api_sign_in organization.founder
      end

      context "when requesting with valid data" do
        it "responds with :created" do
          post :create, params: { organization_id: organization.id, post: post_params }
          respond_with :created
        end

        it "creates post" do
          expect{post :create, params: { organization_id: organization.id, post: post_params }}
            .to change{Post.count}.from(0).to(1)
        end

        it "returns created post" do
          post :create, params: { organization_id: organization.id, post: post_params }
          expect(json_response).to eq(json_for(Post.last))
        end
      end

      context "when requesting with invalid data" do
        before do
          post :create, params: { organization_id: organization.id, post: invalid_post_params }
        end

        it { is_expected.to respond_with :unprocessable_entity }

        it "returns post errors" do
          expect(json_response).to eq({ errors: { title: ["can't be blank"] }})
        end
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in create(:user)
        post :create, params: { organization_id: organization.id, post: post_params }
      end

      it { is_expected.to respond_with :unauthorized }

      it "returns errors" do
        expect(json_response)
          .to eq({ errors: { permissions: 'You have no permissions' }})
      end
    end
  end

  describe "PATCH #update" do
    context "when authorizated" do
      before do
        api_sign_in organization.founder
      end

      context "when requesting with valid data" do
        before do
          patch :update, params: { organization_id: organization.id, id: org_post.id, post: post_params }
        end

        it { is_expected.to respond_with :success }

        it "updates post" do
          expect(Post.last.title).to eq("new title")
        end

        it "returns updated post" do
          expect(json_response).to eq(json_for(Post.last))
        end
      end

      context "when requesting with invalid data" do
        before do
          patch :update, params: { organization_id: organization.id, id: org_post.id, post: invalid_post_params }
        end

        it { is_expected.to respond_with :unprocessable_entity }

        it "returns post errors" do
          expect(json_response).to eq({ errors: { title: ["can't be blank"] }})
        end
      end
    end

    context "when unauthorized" do
      before do
        api_sign_in create(:user)
        patch :update, params: { organization_id: organization.id, id: org_post.id, post: post_params }
      end

      it { is_expected.to respond_with :unauthorized }

      it "returns errors" do
        expect(json_response)
          .to eq({ errors: { permissions: 'You have no permissions' }})
      end
    end
  end
end
