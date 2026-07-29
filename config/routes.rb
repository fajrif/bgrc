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
			resources :snippets
      resources :users, :except => [:new, :create] do
				collection do
					get "export_all" => "users#export_all", :constraints => { :format => :xls }, :as => :export_all
				end
      end
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
					get :calendar
					get "export_all" => "bookings#export_all", :constraints => { :format => :xls }, :as => :export_all
					get :cashier_booking
					post :create_cashier_booking
					get :check_slot
				end
				member do
					get :invoice
					patch :reschedule
					patch :mark_refunded
					post :cancel_credit_booking
				end
      end
      resources :recurring_events do
        collection { get :check_overlaps }
      end
      resources :event_rsvps, only: [:index, :show, :destroy]
      resources :purchases, :only => [:index, :show, :destroy] do
        member do
          put "settlement" => "purchases#settlement", :as => :settlement
        end
				collection do
					get "export_all" => "purchases#export_all", :constraints => { :format => :xls }, :as => :export_all
				end
      end
      resources :class_credit_purchases, :only => [:index, :show, :destroy] do
        member { post :book_on_behalf }
      end
			resources :facilities do
				member do
          delete "delete_attachment_image/:asset_id" => "facilities#delete_attachment_image", :as => :delete_attachment_image
        end
      end
      resources :wellnesses do
        member do
          delete "delete_attachment_image/:asset_id" => "wellnesses#delete_attachment_image", :as => :delete_attachment_image
        end
      end
			resources :sports do
				member do
          delete "delete_attachment_image/:asset_id" => "sports#delete_attachment_image", :as => :delete_attachment_image
          delete 'delete_image/:asset_id', to: 'sports#delete_image', via: :delete, as: :delete_image
        end
      end
			resources :group_classes
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
			resources :packages do
				member do
          delete "delete_attachment_image/:asset_id" => "packages#delete_attachment_image", :as => :delete_attachment_image
        end
      end
			resources :coaches
			resources :items

      resources :golf_courses do
        resources :golf_business_hours, shallow: true
        resources :golf_rates, shallow: true
        resources :golf_items, shallow: true
      end
      resources :golf_reservations, :controller => "golf_reservations" do
        collection do
          get :calendar
          get :tee_times
        end
        member do
          post :cancel
          post :mark_paid
        end
      end
		end

    namespace :users do
      resource :account, :only => [:show, :update] do
				member do
          delete "delete_photo/:asset_id" => "accounts#delete_photo", :as => :delete_photo
        end
      end
      resource :password, :only => [:edit, :update]

      post "purchase/:type/:id" => "purchases#create", :as => :purchase
      get "purchase/:type/:id" => "purchases#new", :as => :new_purchase

      # Bookings (index, destroy stay authenticated; create/show/add_on moved to public)
      resources :bookings, :only => [:index, :destroy] do
        collection do
          get "history" => "bookings#history", :as => :history
          get "calendar" => "bookings#calendar", :as => :calendar
        end
        member do
          get :invoice
          post :reschedule_to_credit
          post :return_credit
        end
      end
      resources :packages, :except => [:edit, :update, :show]
      resources :payments, :only => [:index, :show]
      resources :class_credits, :only => [:index, :destroy], :controller => "class_credits"
      resources :golf_reservations, :only => [:index, :destroy] do
        collection { get :history }
      end
    end

		# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
		# i18n Scope for id

		# Public booking routes (no auth required)
		resources :bookings, only: [:create, :show, :destroy] do
			member do
				patch "add_on/:item_id" => "bookings#add_on", :as => :add_on
				patch "add_quantity/:add_on_id" => "bookings#add_quantity", :as => :add_quantity
				patch "remove_quantity/:add_on_id" => "bookings#remove_quantity", :as => :remove_quantity
				post "expire" => "bookings#expire", :as => :expire
				get :invoice
				post :pay_with_credit
			end
		end

		# AJAX login for booking modal
		post "ajax_login" => "ajax_sessions#create", :as => :ajax_login

    # Golf
    get  'golf',            to: 'golf#index', as: :golf
    get  'golf/tee_times',  to: 'golf#tee_times', as: :golf_tee_times
    resources :golf_reservations, only: [:new, :create, :show, :destroy] do
      member do
        patch "add_on/:golf_item_id" => "golf_reservations#add_on", as: :add_on
        post  :expire
      end
    end

		resources :group_classes, :only => [:index, :show]
		resources :recurring_events, :only => [:show] do
      member { post :rsvp }
    end
		resources :packages, :only => [:index, :show]
		resources :facilities, :only => [:index, :show]
		resources :wellnesses, :only => [:index, :show]
		resources :events, :only => [:index, :show] do
      resources :event_rsvps, :only => [:create], :controller => "event_rsvps"
    end
    resources :class_credit_purchases, :only => [:create, :show] do
      member do
        get  :initiate_payment
        post :payment_callback
        get  :book_session
        post :claim_session
      end
    end
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
    match 'gallery', to: 'home#gallery', via: :get, as: :gallery
    match 'restaurant', to: 'restaurant#index', via: :get, as: :restaurant
    match 'search', to: 'search#index', via: :get, as: :search
    match 'search_selection', to: 'search#search_selection', via: :get, as: :search_selection
    match 'courts/:id/calculate_price', to: 'courts#calculate_price', via: :get, as: :calculate_price
		root :to => "home#index"
  end
end
