Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "stocks.csv", to: "stocks#index"
  get "funds.csv",  to: "funds#index"
  get "ofz.csv",             to: "ofz#index"
  get "corporate_bonds.csv", to: "corporate_bonds#index"
  get "currencies.csv",      to: "currencies#index"
  get "imoex.csv",           to: "imoex#index"
  get "moexbc.csv",          to: "moexbc#index"
end
