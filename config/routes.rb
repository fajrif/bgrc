Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

	mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs'

  devise_for :admins, :controllers => { :sessions => "admins/sessions" }

	scope "(:locale)", locale: /id/ do
		namespace :admins do
			root :to => 'dashboard#index'
			get "account/change_password" => "accounts#change_password", :as => :change_password
			put "account/update_password" => "accounts#update_password", :as => :update_password

			resources :admins
			resources :users
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

		# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
		# i18n Scope for id

		resources :inquiries, :only => [:create]
		resources :articles, :only => [:index, :show]
		resources :facilities, :only => [:index, :show]
		resources :events, :only => [:index, :show]
		resources :promos, :only => [:index, :show]
		resources :sports, :only => [:show]

    match 'about', to: 'home#about', via: :get, as: :about
    match 'terms', to: 'home#terms', via: :get, as: :terms
    match 'privacy', to: 'home#privacy', via: :get, as: :privacy
    match 'faq', to: 'home#faq', via: :get, as: :faq
		root :to => "home#index"
  end
end
