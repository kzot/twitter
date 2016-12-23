Rails.application.routes.draw do
  root 'tweets#index'
  resources :tweets, only: [:index, :new, :show, :edit]
end
