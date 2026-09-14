module VueHelper
	# Mount point for a Vue component registered in app/frontend/components/registry.ts.
	# Anything the block renders shows until the component mounts over it.
	#
	#   <%= vue_component "CourtBookingApp", { court_id: @court.id } do %>
	#     <p>Loading the booking calendar&hellip;</p>
	#   <% end %>
	def vue_component(name, props = {}, **html_options, &block)
		data = (html_options.delete(:data) || {}).merge(vue: name, props: props.to_json)
		content_tag(:div, (capture(&block) if block), **html_options, data: data)
	end
end
