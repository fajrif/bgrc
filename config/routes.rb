Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

  devise_for :user, :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'users/sign_up_by_provider' => 'users/registrations#new_by_provider', :as => :new_user_registration_by_provider
    post 'users/sign_up_by_provider' => 'users/registrations#create_by_provider', :as => :user_registration_by_provider
  end
  devise_for :admins, :controllers => { :sessions => "admins/sessions" }

	scope "(:locale)", locale: /id/ do
		namespace :admins do
			root :to => 'dashboard#index'
			get "account/change_password" => "accounts#change_password", :as => :change_password
			put "account/update_password" => "accounts#update_password", :as => :update_password

			resources :admins
      resources :users, :except => [:new, :create]
			resources :testimonials
			resources :questions

			resources :banners
			resources :banner_sections
			resources :articles do
				member do
					delete "delete_attachment/:asset_id" => "articles#delete_attachment", :as => :delete_attachment
					delete "delete_attachment_image/:asset_id" => "articles#delete_attachment_image", :as => :delete_attachment_image
				end
			end
			resources :categories
			resources :inquiries, :only => [:index, :show, :destroy]
			resources :addresses do
				collection do
					patch :sort
				end
			end
      resources :courts do
        resources :business_hours, :controller => "courts/business_hours"
        resources :costs, :controller => "courts/costs"
        match 'delete_image/:id', to: 'courts#delete_image', via: :delete, as: :delete_image
      end
      resources :bookings do
        collection do
          get "update_select_duration" => "bookings#update_select_duration", :as => :update_select_duration
        end
        member do
          post "send_email_notification" => "bookings#send_email_notification", :as => :send_email_notification
        end
      end
      resources :purchases, :only => [:index, :show, :destroy] do
        member do
          put "settlement" => "purchases#settlement", :as => :settlement
        end
      end
			resources :facilities do
				member do
          delete "delete_attachment_image/:asset_id" => "facilities#delete_attachment_image", :as => :delete_attachment_image
        end
      end
			resources :sports do
				member do
          delete "delete_attachment_image/:asset_id" => "sports#delete_attachment_image", :as => :delete_attachment_image
        end
      end
			resources :events do
				member do
          delete "delete_attachment_image/:asset_id" => "events#delete_attachment_image", :as => :delete_attachment_image
        end
      end
			resources :promos do
				member do
          delete "delete_attachment_image/:asset_id" => "promos#delete_attachment_image", :as => :delete_attachment_image
        end
      end
		end

    namespace :users do
      resource :account, :only => [:show, :update]
      resource :password, :only => [:edit, :update]

      resource :purchase, :only => [:create]
      get "purchase/:type/:id" => "purchases#new", :as => :new_purchase

      # Bookings
      resources :bookings, :except => [:edit, :update, :show] do
        collection do
          get "history" => "bookings#history", :as => :history
        end
      end
    end

		# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
		# i18n Scope for id

		resources :packages, :only => [:index, :show]
		resources :facilities, :only => [:index, :show]
		resources :events, :only => [:index, :show]
		resources :promos, :only => [:index, :show]
		resources :sports, :only => [:show]

    match 'contact', to: 'inquiries#show', via: :get, as: :get_contact
    match 'contact', to: 'inquiries#create', via: :post, as: :contacts
    match 'blogs', to: 'articles#index', via: :get, as: :blogs
    match 'blogs/:id', to: 'articles#show', via: :get, as: :get_blog
    match 'about', to: 'home#about', via: :get, as: :about
    match 'disclaimer', to: 'home#disclaimer', via: :get, as: :disclaimer
    match 'privacy', to: 'home#privacy', via: :get, as: :privacy
    match 'faq', to: 'home#faq', via: :get, as: :faq
		root :to => "home#index"
  end
end
