Rails.application.routes.draw do
  root 'movies#index'

  resources :movies do
    collection do
      get :watched
    end
  end

  resources :genres
end
