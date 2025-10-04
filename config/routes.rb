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

      # nested create/index for screenings on a party
      resources :screenings, only: %i[new create index]

      # nested links (create/destroy) ON a party
      resources :links, only: %i[create destroy]
    end

    # global screenings by id
    resources :screenings, only: %i[show edit update]

    resources :groups do
      get :lookup, on: :collection   # JSON autocomplete
      resources :group_memberships, path: :memberships, only: [ :create, :destroy ]
    end

    resources :parties, param: :public_id do
      post :create_household, on: :member   # quick-create + add member
  end
  end
      namespace :ref do
    resources :regions, only: :index
  end
end
