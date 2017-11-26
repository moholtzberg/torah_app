Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'users'
      devise_for :users, only: []

      resources :users, only: [:index, :show] do
        post :add_to_friends
        post :remove_from_friends
        get :favorites
      end

      resources :subjects, only: [:index, :show] do
        post :like, to: "subjects#like"
        delete :unlike, to: "subjects#unlike"
      end

      resources :organizations do
        resources :posts, only: [:index, :show, :create, :update]
      end

      resources :organization, only: [:index, :show, :create] do
        post "send_invite", to: "memberships#send_invite"
        patch "accept_invite/:user_id", to: "memberships#accept_invite"
        delete "cancel_invite", to: "memberships#cancel_invite"
        get "members", to: "memberships#members"
        get "candidates", to: "memberships#candidates"
        patch "change_role/:user_id/:role", to: "memberships#change_role"
      end

      resources :notifications, only: [:create, :index, :destroy] do
        collection do
          patch :mark_as_read
        end
      end

      resources :lessons, except: [:new, :edit] do
        collection do
          get "subjects/:name", to: "lessons#subjects"
        end
      end

      resources :chatrooms, only: [:index, :show, :create] do
        post "add_participant/:user_id", to: "chatrooms#add_participant"
        get :video_token, to: "chatrooms#video_token"
        get :messages, to: "chatrooms#messages"
      end
    end
  end

  resources :notifications, only: [:create, :index, :destroy] do
    collection do
      post :mark_as_read
      post :subscribe
      get :fetch
    end
  end

  root "subjects#home"

  get "organizations/fetch", to: "organizations#fetch"
  get "organizations/home", to: "organizations#home"
  resources :organizations do
    resources :posts
    post "send_invite", to: "memberships#send_invite", as: "send_invite"
    patch "accept_invite/:user_id", to: "memberships#accept_invite", as: "accept_invite"
    delete "cancel_invite", to: "memberships#cancel_invite", as: "cancel_invite"
    get "members", to: "memberships#members", as: "members"
    patch "change_role/:user_id/:role", to: "memberships#change_role", as: "change_role"
  end

  #devise_for :users
  get "subjects/fetch", to: "subjects#fetch"
  resources :subjects

  scope "users" do
    get "fetch_users", to: "users#fetch_users"
    post "add_friend/:id", to: "users#add_friend", as: "add_friend"
    delete "remove_friend/:id", to: "users#remove_friend", as: "remove_friend"
  end

  resources :users, only: [:show, :index, :edit, :update] do
    patch :change_password
    get :favorites
    resources :lessons, only: [:create, :new, :index, :destroy]
  end

  get "fetch_lessons", to: "lessons#fetch_lessons", as: "fetch_lessons"
  get "lessons/fetch_subjects", to: "lessons#fetch_subjects"
  post "lessons/:id/accept_invite", to: "lessons#accept_invite", as: "accept_lesson_invite"
  delete "lessons/:id/decline_invite", to: "lessons#decline_invite", as: "decline_lesson_invite"

  post "add_subject/:id", to: "users#add_subject", as: "add_subject"
  delete "remove_subject/:id", to: "users#remove_subject", as: "remove_subject"

  resources :chatrooms, only: [:index, :show] do
    post "add_participant/:user_id", to: "chatrooms#add_participant", as: "add_participant"
    get "fetch_users", to: "chatrooms#fetch_users", as: "fetch_users"
  end
  post "chatrooms/:user_id", to: "chatrooms#create", as: "new_chatroom"

  get "chatrooms/video_token/:chatroom_id", to: "chatrooms#generate_video_token"

  mount ActionCable.server => '/cable'

  scope :admin do
    get "edit_user/:id", to: "admin#edit_user", as: "admin_edit_user"
    patch "update_user/:id", to: "admin#update_user", as: "admin_update_user"
  end

  namespace :admin do
    resources :organizations, only: [:show, :index] do
      collection do
        get :fetch
      end
      patch :confirm
    end
  end

  get "/:organization_name", to: "organizations#show_by_name", as: "organization_page"
end
