Rails.application.routes.draw do
  root "subjects#home"
  get :home, to: "users#home"

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

  resources :organizations do
    collection do
      get :fetch
      get :home
      get :home_fetch
    end

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
  resources :users, only: [:show, :index, :edit, :update] do
    collection do
      get :fetch
    end
    post :friend_request
    post :accept_request
    delete :remove_friend

    patch :change_password
    get :favorites
    resources :lessons, only: [:create, :new, :index, :destroy] do
      collection do
        get :subjects
        get :fetch
      end
    end
  end

  resources :lessons, only: [] do
    collection do
      get :check_if_current_user_is_available
      get :subjects
    end

    post :accept_invite
    delete :decline_invite
  end

  post "add_subject/:id", to: "users#add_subject", as: "add_subject"
  delete "remove_subject/:id", to: "users#remove_subject", as: "remove_subject"

  resources :chatrooms, only: [:index, :show] do
    post :end_video_chat
    post "add_participant/:user_id", to: "chatrooms#add_participant", as: "add_participant"
    get :fetch_users
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
