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
        post :create_household
      end

      resources :emails, only: %i[new create edit update destroy] do
        member { patch :primary; get :reveal }
      end
      resources :phones, only: %i[new create edit update destroy] do
        member { patch :primary }
      end
      resources :addresses, only: %i[index new create edit update destroy] do
        member { patch :primary }
      end

      # Party-scoped "join group" modal + create
      resources :group_memberships, path: :memberships, only: %i[new create]

      resources :links, only: %i[create destroy]
      resources :screenings, only: %i[new create index]
    end

    resources :screenings, only: %i[show edit update]

    # Add :edit and :update to enable rename modal
    resources :groups, only: %i[index show edit update destroy] do
      get :lookup, on: :collection


      # Group-scoped join/leave (singular resource gives helper: party_group_membership_path(group))
      resource :membership,
              only: %i[create destroy],
              controller: "groups/memberships"
    end

    resources :link_suggestions,  only: %i[index update]
    resources :group_suggestions, only: %i[index update]
  end


  namespace :ref do
    resources :regions, only: :index
  end
end
