module LocaleHelper

	def get_locale_current_page_route
		content_tag(:ul, class: "dropdown-menu box-shadow-light") do
			path = request.path
			if path == "/id"
				en_path = "/"
				id_path = "/id"
			else
				en_path = url_for(locale: nil)
				id_path = url_for(locale: :id)
			end

			content_tag(:li) do
				content_tag(:a, "English", href: en_path)
			end +
			content_tag(:li) do
				content_tag(:a, "Indonesia", href: id_path)
			end
		end
	end

	def get_current_user_menu_routes
		content_tag(:ul, class: "dropdown-menu box-shadow-light my-account") do
			content_tag(:li) do
				content_tag(:a, "My Account", href: users_account_path)
			end +
			content_tag(:li) do
				content_tag(:a, "My Bookings", href: users_bookings_path)
			end +
			content_tag(:li) do
				content_tag(:a, "Class Credits", href: users_class_credits_path)
			end +
			content_tag(:li) do
				content_tag(:a, "Payment", href: users_payments_path)
			end +
			content_tag(:li) do
				content_tag(:a, "Log Out", href: users_logout_path)
			end
		end
	end

end
