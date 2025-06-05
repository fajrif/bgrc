module LocaleHelper

	def get_locale_current_page_route
		content_tag(:ul, class: "dropdown-menu") do
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

end
