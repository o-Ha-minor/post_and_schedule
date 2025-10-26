Rails.application.routes.draw do
  namespace :api do
    namespace :auth do
      get "check", to: "sessions#check"
      post "login", to: "sessions#login"
      post "register", to: "sessions#register"
      delete "logout", to: "sessions#logout"
    end

    resources :posts do
      resources :comments, only: [ :create, :destroy ]
    end

    resources :users, only: [ :index, :show, :create, :update, :destroy ] do
      collection do
        patch :update_avatar
        patch :update_ai_images
        patch :update_ai_expression
      end
    end
    resources :tasks do
      post :completed, on: :member
    end

    resources :events
    resources :likes, only: [ :create, :destroy ]

    resources :groups, only: [ :index, :show, :create ] do
      post "join", on: :member
      delete "leave", on: :member
    end

    resources :ai_images, only: [ :index ] do
      collection do
        get :generate_image_url
      end
    end
  end

  # SPA entry (Vue が全ての表示を担当)
  root to: "home#spa"

  # 開発中の便利ルート
  get "about" => "home#about"

  # config/routes.rb
  get "/favicon.ico", to: redirect("/assets/favicon.ico")

  # SPA 用キャッチオール（HTML を要求するリクエストだけ）
  get "*path", to: "home#spa", constraints: ->(request) {
    !request.xhr? && request.format.html?
  }
end
