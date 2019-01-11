Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :search, only: :index
      resources :nodes, only: :show
    end
  end
end
