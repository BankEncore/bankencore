Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "home#index"

  namespace :party do
    resources :parties, param: :public_id do
      member { get :reveal_tax_id }  # /party/parties/:public_id/reveal_tax_id
      post :reveal_tax_id   # new POST for the Stimulus controller

      resource  :person,       only: %i[show create update destroy]
      resource  :organization, only: %i[show create update destroy]

      resources :emails, only: %i[index create update destroy] do
        member { get :reveal } # /party/parties/:public_id/emails/:id/reveal
      end
      resources :phones,    only: %i[index create update destroy]
      resources :addresses, only: %i[index create update destroy]
    end

    resources :groups do
      resources :group_memberships, path: :memberships, only: %i[index create destroy]
    end

    resources :links, only: %i[index create destroy]
  end

  namespace :ref do
    resources :regions, only: :index  # /ref/regions?country=US
  end
end
