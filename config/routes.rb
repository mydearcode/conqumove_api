Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  mount ActionCable.server => "/cable"

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"
      get "auth/me", to: "auth#me"

      post "session/start", to: "sessions#start"
      post "session/end", to: "sessions#finish"
      post "movement/batch", to: "movement_batches#create"
      get "territories/nearby", to: "territories#nearby"
    end
  end
end
