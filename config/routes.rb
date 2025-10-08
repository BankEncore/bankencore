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

  # --- Party domain ---
  namespace :party do
    resources :parties, param: :public_id do
      collection { get :lookup }
      member     { post :create_household }
      member     { get  :reveal_tax_id } # legacy optional

      resources :identifiers, only: [ :show ] do
        member { get :reveal } # /party/parties/:public_id/identifiers/:id/reveal
      end

      resources :emails, only: %i[new create edit update destroy] do
        member do
          patch :primary
          get   :reveal
        end
      end

      resources :phones, only: %i[new create edit update destroy] do
        member { patch :primary }
      end

      resources :addresses, only: %i[index new create edit update destroy] do
        member { patch :primary }
      end

      resources :group_memberships, path: :memberships, only: %i[new create]
      resources :links,            only: %i[create destroy]
      resources :link_suggestions, only: %i[index update]
      resources :screenings,       only: %i[new create index]
    end

    resources :screenings, only: %i[show edit update]

    resources :groups, only: %i[index show edit update destroy] do
      collection { get :lookup }
      resource :membership, only: %i[create destroy], controller: "groups/memberships"
    end

    resources :group_suggestions, only: %i[index update]
  end

  # --- Reference data ---
  namespace :ref do
    resources :regions, only: :index
  end

  resource :profile, only: [] do
    patch :time_zone
  end
end
