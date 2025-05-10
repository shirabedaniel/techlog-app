Rails.application.routes.draw do
  get "home/top"
  
  get "up" => "rails/health#show", as: :rails_health_check

  # root "posts#index"
end
