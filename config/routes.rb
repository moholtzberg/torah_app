Rails.application.routes.draw do
  root "subjects#index"
  devise_for :users
  resources :subjects
  resources :users, only: [:show, :index]
  post "add_subject/:id", to: "users#add_subject"

  resources :chatrooms, only: [:index, :show]
  post "chatrooms/:user_id", to: "chatrooms#create", as: "new_chatroom"

  get "chatrooms/video_token/:chatroom_id", to: "chatrooms#generate_video_token"

  mount ActionCable.server => '/cable'
end
