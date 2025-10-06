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
      get :lookup, on: :collection   # JSON search for target party picker
      member do
        get  :reveal_tax_id
        post :reveal_tax_id
        post :create_household
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

      # Party-scoped "join group" modal + create
      resources :group_memberships, path: :memberships, only: %i[new create]

      # Links + suggestions scoped to a source party
      resources :links,             only: %i[create destroy]           # Party::LinksController
      resources :link_suggestions,  only: %i[index update]             # Party::LinkSuggestionsController

      resources :screenings, only: %i[new create index]
    end

    resources :screenings, only: %i[show edit update]

    # Groups
    resources :groups, only: %i[index show edit update destroy] do
      get :lookup, on: :collection
      # Group-scoped join/leave
      resource :membership, only: %i[create destroy], controller: "groups/memberships"
    end

    # Global group suggestions (not tied to a single party)
    resources :group_suggestions, only: %i[index update]
  end

  namespace :ref do
    resources :regions, only: :index
  end
end
