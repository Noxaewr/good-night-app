# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs' if defined?(Rswag::Ui::Engine)
  mount Rswag::Api::Engine => '/api-docs' if defined?(Rswag::Api::Engine)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
  # API V1 routes
  namespace :v1 do
    resources :users, only: %i[index show create] do
      member do
        # Follow/Unfollow actions
        post :follow
        delete :unfollow

        # Get following and followers lists
        get :following
        get :followers

        # Get following users' sleep records
        get :following_sleep_records, to: 'sleep_records#following_sleep_records'
      end

      # Nested sleep records
      resources :sleep_records, only: %i[index create]
    end
  end

  # Legacy routes (for backward compatibility)
  resources :users, only: %i[index show create] do
    member do
      get :following_sleep_records, to: 'sleep_records#following_sleep_records'
      post :follow
      delete :unfollow
      get :following
      get :followers
    end
    resources :sleep_records, only: %i[index create]
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
