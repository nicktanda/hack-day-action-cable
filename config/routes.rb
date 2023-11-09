Rails.application.routes.draw do
  get "/login", to: "sessions#new", as: "new_session"
  post "/login", to: "sessions#create", as: "create_session"
  get "/logout", to: "sessions#destroy", as: "destroy_session"

  root to: "conversations#index"
  get "/conversations/:id", to: "conversations#show", as: "show_conversation"
  post "/messages", to: "messages#create", as: "create_message"
end
