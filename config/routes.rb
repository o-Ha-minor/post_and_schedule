Rails.application.routes.draw do
  namespace :api do
    namespace :auth do
      get :check
      post :login
      post :register
      delete :logout
    end

    resources :posts do
      resources :comments, only: [ :create, :destroy ]
    end

    resources :users, only: [ :index, :show, :create, :update, :destroy ]
    resources :tasks do
      post :completed, on: :member
    end
    resources :events
    resources :likes, only: [ :create, :destroy ]
    resources :groups, only: [ :index, :show, :create ] do
      post "join", on: :member
      delete "leave", on: :member
    end
  end

  # SPA entry (Vue が全ての表示を担当)
  root to: "home#spa"

  # 開発中の便利ルート
  get "about" => "home#about"

  # 古い HTML ログイン/ユーザー管理は API に切り替えるなら削除してOK。
  # 今すぐ消すのが怖ければ残しておいても良いですが、重複に注意。

  # SPA 用キャッチオール（HTML を要求するリクエストだけ）
  get "*path", to: "home#spa", constraints: ->(request) {
    !request.xhr? && request.format.html?
  }
end
