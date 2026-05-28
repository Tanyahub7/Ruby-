Rails.application.routes.draw do
  root 'movies#index'

  resources :movies do
    collection do
      get :watched
      get :released_this_year
    end
    resources :actors, only: %i[create edit update destroy]
  end

  resources :genres
end
