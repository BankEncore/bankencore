# config/routes.rb
Rails.application.routes.draw do
  # sessions
  resource :session, only: %i[new create destroy]
  get    "sign_in",  to: "sessions#new",     as: :sign_in
  delete "sign_out", to: "sessions#destroy", as: :sign_out

  # hidden admin scope
  namespace :admin, path: "/_internal/admin" do
    resources :users, only: %i[index new create edit update destroy]
  end

  # health + root
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  namespace :party do
    resources :parties, param: :public_id do
      member do
        get  :reveal_tax_id
        post :reveal_tax_id
      end

      resources :emails,    only: %i[new create edit update destroy] do
        member { patch :primary; get :reveal }
      end
      resources :phones,    only: %i[new create edit update destroy] do
        member { patch :primary }
      end
      resources :addresses, only: %i[index new create edit update destroy] do
        member { patch :primary }
      end

      # nested create/index for screenings
      resources :screenings, only: %i[new create index]
    end

    # global screenings by id
    resources :screenings, only: %i[show edit update]

    resources :groups do
      resources :group_memberships, path: :memberships, only: %i[index create destroy]
    end

    resources :links, only: %i[index create destroy]
  end

  namespace :ref do
    resources :regions, only: :index
  end
end
