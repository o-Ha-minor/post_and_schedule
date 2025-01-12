Rails.application.routes.draw do
  resources :events, only: [ :index, :create, :update, :destroy, :new, :edit, :show ]
  resources :likes, only: [ :create, :destroy ]
  post "/events/:id", to: "events#destroy"

  get "/" => "home#top", as: "home_top"
  get "about" => "home#about"

  get "/posts/index" => "posts#index"
  get "posts/new" => "posts#new"
  post "posts/create" => "posts#create"
  get "posts/:id" => "posts#show"
  get "posts/:id/edit" => "posts#edit"
  post "posts/:id/update" => "posts#update"
  post "posts/:id/destroy" => "posts#destroy"

  get "tasks" => "tasks#index"
  get "tasks/new" => "tasks#new"
  post "tasks/create" => "tasks#create"
  post "tasks/:id/completed" => "tasks#completed"
  get "tasks/:id" => "tasks#show"
  get "tasks/:id/edit" => "tasks#edit"
  post "tasks/:id/update" => "tasks#update"
  post "tasks/:id/destroy" => "tasks#destroy"

  get "users/index" => "users#index"
  get "users/new" => "users#new"
  post "users/create" => "users#create"
  get "users/:id" => "users#show"
  get "users/:id/edit" => "users#edit"
  post "users/:id/update" => "users#update"
  get "login" => "users#login_form"
  post "login" => "users#login"
  post "logout" => "users#logout"
  post "users/:id/destroy" => "users#destroy"
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
    resources :posts
    resources :users
    resources :tasks
    resources :tasks do
      post :completed, on: :member
    end
    resources :posts do
      post "/comments/:id" => "comments#destroy"
      resources :comments, only: [ :create ] do
        resources :likes, only: [ :create, :destroy ]
      end
    end


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
