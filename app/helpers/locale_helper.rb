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
				content_tag(:a, href: en_path) do
					content_tag(:i, nil, class: "icon-country usa") + "English"
				end
			end +
			content_tag(:li) do
				content_tag(:a, href: id_path) do
					content_tag(:i, nil, class: "icon-country indonesia") + "Indonesia"
				end
			end

		end
	end

end
