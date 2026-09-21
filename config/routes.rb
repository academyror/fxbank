# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :accounts, only: %i[index show] do
    resources :transfers, only: %i[new]
  end

  resources :transfers, only: %i[create show]

  root "home#index"
end
