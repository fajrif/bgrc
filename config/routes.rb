Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

  # 301 a retired URL to its replacement. Rails' own `redirect("/x")` would drop
  # both the "(:locale)" prefix every public route carries and the query string
  # (which /search relies on), so the target is rebuilt from the request.
  moved_to = ->(path) {
    redirect { |params, request|
      target = params[:locale].present? ? "/#{params[:locale]}#{path}" : path
      request.query_string.present? ? "#{target}?#{request.query_string}" : target
    }
  }

  devise_for :user, :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks", :passwords => "users/devise_passwords" }
  devise_scope :user do
    get 'users/sign_up_by_provider' => 'users/registrations#new_by_provider', :as => :new_user_registration_by_provider
    post 'users/sign_up_by_provider' => 'users/registrations#create_by_provider', :as => :user_registration_by_provider
  end
  devise_for :admins, :controllers => { :sessions => "admins/sessions" }

  # Server-to-server payment notifications. Deliberately outside the "(:locale)"
  # scope below: gateways post to a fixed URL and must not be locale-rewritten.
  post "webhooks/xendit"   => "webhooks/xendit#create",   :as => :xendit_webhook
  post "webhooks/midtrans" => "webhooks/midtrans#create", :as => :midtrans_webhook

  # Friendly aliases for the two Devise pages the public site links to.
  devise_scope :user do
    get 'login',    to: 'users/sessions#new',      as: :login
    get 'register', to: 'users/registrations#new', as: :register
  end

	scope "(:locale)", locale: /id/ do
		namespace :admins do
			root :to => 'dashboard#index'
			get "account/change_password" => "accounts#change_password", :as => :change_password
			put "account/update_password" => "accounts#update_password", :as => :update_password

			resources :admins
			resources :snippets
      resources :users, :except => [:new] do
				collection do
					get "export_all" => "users#export_all", :constraints => { :format => :xls }, :as => :export_all
					get :search
				end
				member do
					post :send_confirmation
					post :send_reset_password
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
			resources :highlights do
				member do
					delete "delete_attachment_image/:asset_id" => "highlights#delete_attachment_image", :as => :delete_attachment_image
					delete "delete_image/:asset_id" => "highlights#delete_image", :as => :delete_image
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
      resources :event_types do
        member do
          delete "delete_banner/:asset_id" => "event_types#delete_banner", :as => :delete_banner
          delete "delete_image/:asset_id"  => "event_types#delete_image",  :as => :delete_image
          put    "move_image_up/:asset_id"   => "event_types#move_image_up",   :as => :move_image_up
          put    "move_image_down/:asset_id" => "event_types#move_image_down", :as => :move_image_down
        end
      end
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
          delete "delete_banner/:asset_id" => "facilities#delete_banner", :as => :delete_banner
          delete "delete_middle_banner/:asset_id" => "facilities#delete_middle_banner", :as => :delete_middle_banner
          delete "delete_image/:asset_id" => "facilities#delete_image", :as => :delete_image
          put "move_image_up/:asset_id" => "facilities#move_image_up", :as => :move_image_up
          put "move_image_down/:asset_id" => "facilities#move_image_down", :as => :move_image_down
        end
      end
      resources :amenities
      resources :facility_details
      resources :facility_rates
      resources :treatments
      resources :restaurants do
        member do
          delete "delete_banner/:asset_id" => "restaurants#delete_banner", :as => :delete_banner
          delete "delete_middle_banner/:asset_id" => "restaurants#delete_middle_banner", :as => :delete_middle_banner
          delete "delete_attachment_image/:asset_id" => "restaurants#delete_attachment_image", :as => :delete_attachment_image
          delete "delete_image/:asset_id" => "restaurants#delete_image", :as => :delete_image
        end
      end
      resources :menus
      resources :menu_categories
      resources :food_orders, only: [:index, :show, :destroy] do
        member do
          put "fulfillment" => "food_orders#fulfillment", :as => :fulfillment
          put "cancel" => "food_orders#cancel", :as => :cancel
          post "cashier_payment" => "food_orders#cashier_payment", :as => :cashier_payment
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
			resources :team_members
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

    # The member area is addressed as /account/*, but the controllers and the
    # `users_*` helper names stay put — `path:` moves the URL without touching
    # the ~40 call sites that build links into it.
    namespace :users, path: "account" do
      resource :account, :only => [:show, :update], :path => "" do
				member do
          delete "delete_photo/:asset_id" => "accounts#delete_photo", :as => :delete_photo
        end
      end
      resource :password, :only => [:edit, :update]
      get "logout" => "accounts#logout", :as => :logout

      # Opens a checkout. Results arrive at /webhooks/*, never from the browser.
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
      resources :payments, :only => [:index, :show], :path => "payment"
      resources :class_credits, :only => [:index, :destroy], :controller => "class_credits", :path => "credits"
      resources :golf_reservations, :only => [:index, :destroy] do
        collection { get :history }
      end
      resources :food_orders, :only => [:index], :path => "orders" do
        collection { get :history }
      end
    end

    # The member area used to live under /users/*. Three of its segments were
    # renamed in the move, so the leading one is rewritten before redirecting.
    get 'users/*rest', to: redirect { |params, request|
      rest = params[:rest].to_s
                          .sub(%r{\Aaccount(/|\z)}, '')
                          .sub(%r{\Aclass_credits(/|\z)}, 'credits\1')
                          .sub(%r{\Apayments(/|\z)}, 'payment\1')
      prefix = params[:locale].present? ? "/#{params[:locale]}" : ""
      target = "#{prefix}/account#{"/#{rest}" if rest.present?}"
      request.query_string.present? ? "#{target}?#{request.query_string}" : target
    }

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

		# Grab & Go orders. Guests can place one; payment is what needs an account,
		# so these sit outside the users namespace like bookings and golf.
		resources :food_orders, path: "orders", only: [:create, :show, :destroy] do
			member do
				post :expire
				get  :invoice
			end
		end

		# AJAX login for booking modal
		post "ajax_login" => "ajax_sessions#create", :as => :ajax_login

    # Booking hub. Golf and Racquet Sports keep their existing controllers and
    # helper names — only the address moved — so the ~40 `golf_path`/`search_path`
    # call sites across the site did not have to change.
    get 'book',                to: 'book#index',        as: :book
    get 'book/golf',           to: 'golf#index',        as: :golf
    get 'book/golf/tee_times', to: 'golf#tee_times',    as: :golf_tee_times
    get 'book/fitness',        to: 'book#fitness',      as: :book_fitness
    get 'book/spa-wellness',   to: 'book#spa_wellness', as: :book_spa_wellness
    get 'book/dining',         to: 'book#dining',       as: :book_dining
    # Clean per-sport addresses for the Racquet Sports hub tab's flyout. All
    # three render the exact same search#index page as /book/racquet-sports,
    # just pre-selecting the sport from the URL instead of a ?sport_id= param.
    get 'book/tennis',     to: 'search#index', as: :search_tennis,     defaults: { sport_slug: 'tennis' }
    get 'book/padel',      to: 'search#index', as: :search_padel,      defaults: { sport_slug: 'padel' }
    get 'book/pickleball', to: 'search#index', as: :search_pickleball, defaults: { sport_slug: 'pickleball' }
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
		# /events/:slug is an EventType page (Weddings, Corporate, ...). The nested
		# RSVP route still belongs to the legacy Event model and is left alone.
		resources :events, :only => [:index] do
      resources :event_rsvps, :only => [:create], :controller => "event_rsvps"
    end
    get 'events/:id', to: 'events#show', as: :event_type
    resources :class_credit_purchases, :only => [:create, :show] do
      member do
        get  :initiate_payment
        get  :book_session
        post :claim_session
      end
    end
		resources :promos, :only => [:index, :show]
		resources :sports, :only => [:show]
		resources :highlights, :only => [:index, :show]

    # Club Life — a section sits under its parent: /club-life/racquet-sports/tennis.
    # Children addressed at their old flat URL are redirected by the controller,
    # which is also where the two renamed Golf slugs are kept alive.
    get 'club-life', to: 'club_life#index', as: :club_life
    # MITS Academy is an About page; Racquet Sports only signposts it.
    get 'club-life/racquet-sports/mits-academy', to: moved_to.call('/about/mits-academy')
    get 'club-life/:section',     to: 'club_life#show', as: :club_life_section
    get 'club-life/:section/:id', to: 'club_life#show', as: :club_life_child

    match 'contact', to: 'inquiries#show', via: :get, as: :get_contact
    match 'contact', to: 'inquiries#create', via: :post, as: :contacts
    match 'blog', to: 'articles#index', via: :get, as: :blogs
    match 'blog/:id', to: 'articles#show', via: :get, as: :get_blog
    match 'about', to: 'home#about', via: :get, as: :about
    match 'disclaimer', to: 'home#disclaimer', via: :get, as: :disclaimer
    match 'privacy-policy', to: 'home#privacy', via: :get, as: :privacy
    match 'terms-conditions', to: 'home#terms', via: :get, as: :terms
    match 'faq', to: 'home#faq', via: :get, as: :faq
    # The three About sub-pages keep their helper names; only the address moved.
    match 'about/gallery', to: 'home#gallery', via: :get, as: :gallery
    match 'about/team', to: 'home#our_team', via: :get, as: :our_team
    match 'about/mits-academy', to: 'home#mits_academy', via: :get, as: :mits_academy
    get 'dining',     to: 'restaurants#index', as: :dining
    get 'dining/:id', to: 'restaurants#show',  as: :dining_restaurant
    match 'book/racquet-sports', to: 'search#index', via: :get, as: :search
    match 'search_selection', to: 'search#search_selection', via: :get, as: :search_selection

    # Retired addresses. `moved_to` keeps the locale prefix and the query string —
    # /search is always reached with ?sport_id=&date=, and /blogs, /gallery and
    # /our-team all carry filter params of their own.
    get 'golf',         to: moved_to.call('/book/golf')
    get 'search',       to: moved_to.call('/book/racquet-sports')
    get 'blogs',        to: moved_to.call('/blog')
    get 'blogs/:id',    to: redirect { |params, request|
      prefix = params[:locale].present? ? "/#{params[:locale]}" : ""
      "#{prefix}/blog/#{params[:id]}"
    }
    get 'privacy',      to: moved_to.call('/privacy-policy')
    get 'terms',        to: moved_to.call('/terms-conditions')
    get 'gallery',      to: moved_to.call('/about/gallery')
    get 'our-team',     to: moved_to.call('/about/team')
    get 'mits-academy', to: moved_to.call('/about/mits-academy')
    match 'courts/:id/calculate_price', to: 'courts#calculate_price', via: :get, as: :calculate_price
		root :to => "home#index"
  end
end
