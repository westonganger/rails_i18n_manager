RailsI18nManager::Engine.routes.draw do
  resources :translations, only: [:index, :show, :edit, :update, :destroy] do
    collection do
      post :translate_missing

      get :import
      post :import

      delete :delete_inactive_keys
    end
  end

  resources :translation_apps

  get "/robots", to: "application#robots", constraints: ->(req){ req.format == :text }

  get "/", to: "translations#index"

  root "translations#index"
end
