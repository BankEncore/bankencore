Rails.application.routes.draw do
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
    end

    resources :groups do
      resources :group_memberships, path: :memberships, only: %i[index create destroy]
    end

    resources :links, only: %i[index create destroy]

    resources :parties, param: :public_id do
    resources :screenings, only: [ :new, :create, :index ]
  end
    resources :screenings, only: [ :show, :edit, :update ]
  end

  namespace :ref do
    resources :regions, only: :index
  end

  namespace :ref do
    resources :regions, only: :index
  end

  def index
    redirect_to party_party_path(@party.public_id, anchor: "addresses")
  end
end
