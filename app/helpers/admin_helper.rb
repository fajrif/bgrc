module AdminHelper

  def blank_or_not(object,blank='-')
    if object.blank?
      blank
    else
      if block_given?
        yield
      else
        object
      end
    end
  end

	def flash_message
    message = ""
    flash.each do |name, msg|
			message += content_tag :div, :class => "alert alert-#{name.to_sym == :notice ? 'success' : 'danger'} alert-dismissible alert-label-icon label-arrow fade show" do
				lbl = if name.to_sym == :notice
					content_tag(:i, nil, class: "ri-notification-off-line label-icon") + content_tag(:strong, "Success")
				else
					content_tag(:i, nil, class: "ri-error-warning-line label-icon") + content_tag(:strong, "Danger")
				end
				lbl += " - #{msg}"
				lbl += content_tag(:button, nil, class: "btn-close", "data-bs-dismiss": "alert", "aria-label": "Close")
			end unless msg == true
    end
    message.html_safe
  end

	def flash_message2
    message = ""
    flash.each do |name, msg|
			css_class = case name.to_sym
				when :notice then 'success'
				when :warning then 'warning'
				else 'danger'
			end
			message += content_tag :div, :class => "alert alert-#{css_class} mb-0 alert-dismissible alert-label-icon label-arrow fade show" do
				lbl = raw(msg)
				lbl += content_tag(:a, nil, class: "btn-close", "data-bs-dismiss": "alert", "aria-label": "Close") do
					content_tag(:i, nil, class: "fa-solid fa-close text-white-2")
				end
			end unless msg == true
    end
		flash.discard
    message.html_safe
  end

	def colorize(object)
		hash = object.hash # hash an object, returns a Fixnum
		trimmed_hash = hash & 0xffffff # trim the hash to the size of 6 hex digits (& is bit-wise AND)
		hex_code = "%06x" % trimmed_hash # format as at least 6 hex digits, pad with zeros
		return "##{hex_code}"
	end

	def get_input_date_value(field, format='%d/%m/%Y %H:%M')
		field.nil? ? '' : field.strftime(format)
	end

	def sortable(column, title = nil)
    title ||= column
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    link_tag = link_to title.titleize, params.merge(:sort => column, :direction => direction, :page => nil)
    icon_tag = column == params[:sort] ? "&nbsp;<i class='#{direction == "asc" ? "icon-arrow-up" : "icon-arrow-down"}'></i>" : ""
    link_tag + icon_tag.html_safe
  end

	def empty_data_message(model, new_link)
		raw("Currently there are no data #{model.model_name.human.pluralize.downcase} at the moment. Please create one by clicking #{link_to "here", new_link}.")
	end

	def title_page(page_title)
    content_for(:title) do
			content_tag(:div, :class => "row") do
				content_tag(:div, :class => "col-12") do
					content_tag(:div, :class => "page-title-box d-sm-flex align-items-center justify-content-between") do
						content_tag(:h4, page_title, :class => "mb-sm-0")
					end
				end
			end
		end
  end

	def current_path?(*path)
		re = Regexp.union(path)
		return 'active' if request.path.match(re)
		''
  end

	def get_banner_styles
		[['0', 'dark-theme'], ['1', 'light-theme']]
	end

	def get_banner_sizes
		[['0', 'large'], ['1', 'medium'], ['2', 'small']]
	end

	def get_published_status
		[[0, 'Draft'], [1, 'Published']]
	end

	def option_sections
    Question::SECTIONS
	end

	def populate_array_of_time
		["06:00",
		"07:00",
		"08:00",
		"09:00",
		"10:00",
		"11:00",
		"12:00",
		"13:00",
		"14:00",
		"15:00",
		"16:00",
		"17:00",
		"18:00",
		"19:00",
		"20:00",
		"21:00",
		"22:00",
		"23:00",
		"00:00",
		"01:00",
		"02:00",
		"03:00",
		"04:00",
		"05:00"]
	end

	def has_asset?(path)
		(Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(path) != nil
	end

	def replace_non_break(title)
		return title.gsub(/<br\/>/,' ')
	end

	# <span class="badge bg-primary">Primary</span>
	def badge_true_false_status(val, txt=nil)
		content_tag(:span, txt || val.to_s, class: "badge bg-#{val == 1 ? 'primary' : 'danger'}")
	end

	# <span class="badge bg-primary-subtle text-primary badge-border">Primary</span>
	def badge_route_category(route_category)
		case route_category
		when 1
			cls = "info"
			lbl = "link-route"
		when 2
			cls = "primary"
			lbl = "object"
		else
			return route_category
		end
		return content_tag(:span, lbl, class: "badge bg-#{cls}-subtle text-#{cls} badge-border")
	end

	# <span class="badge rounded-pill border border-primary text-primary">Primary</span>
	def badge_member_type(member_type)
		if member_type
			case member_type.id
			when 1
				cls = "secondary"
			when 2
				cls = "success"
			else
				cls = "dark"
			end
			return content_tag(:span, member_type.name, class: "badge rounded-pill border border-#{cls} text-#{cls} badge-border")
		end
	end

	# <span class="badge badge-label bg-primary"><i class="mdi mdi-circle-medium"></i> Primary</span>
	def badge_category(category)
		if category
			case category.id
			when 1
				cls = "primary"
			when 2
				cls = "secondary"
			when 3
				cls = "success"
			when 4
				cls = "danger"
			when 5
				cls = "warning"
			when 6
				cls = "info"
			when 7
				cls = "dark"
			when 8
				cls = "primary"
			when 9
				cls = "secondary"
			when 10
				cls = "success"
			when 11
				cls = "danger"
			when 12
				cls = "warning"
			when 13
				cls = "info"
			when 14
				cls = "dark"
			else
				cls = "light"
			end
			return content_tag(:span, class: "badge badge-label bg-#{cls}") do
				content_tag(:i, nil, class: "mdi mdi-circle-medium") + " #{category.name}"
			end
		end
	end

  def is_home_page?
    controller.controller_name == "home" && controller.action_name == "index"
  end

  def is_bookings_page?
    controller.controller_name == "bookings" && controller.action_name == "index"
  end

  def is_calendar_page?
    controller.controller_name == "bookings" && controller.action_name == "calendar"
  end

	def is_admins_dashboard_page?
		controller.controller_name == "dashboard"
	end

  def is_admins_articles_page?
		controller.controller_name == "articles" ||
		controller.controller_name == "highlights" ||
		controller.controller_name == "categories"
  end

  def is_admins_banners_page?
		controller.controller_name == "banners" ||
		controller.controller_name == "banner_sections"
  end

  def is_admins_page?
		controller.controller_name == "admins"
  end

  def is_admins_users_page?
		controller.controller_name == "users" ||
		controller.controller_name == "bookings" ||
		controller.controller_name == "coaches"
  end

	def is_admins_dining_page?
		controller.controller_name == "restaurants" ||
		controller.controller_name == "menus" ||
		controller.controller_name == "menu_categories" ||
		controller.controller_name == "food_orders"
	end

	def is_admins_sports_page?
		controller.controller_name == "sports" ||
		controller.controller_name == "courts" ||
		controller.controller_name == "business_hours" ||
		controller.controller_name == "costs" ||
		controller.controller_name == "facilities" ||
		controller.controller_name == "amenities" ||
		controller.controller_name == "facility_details" ||
		controller.controller_name == "facility_rates" ||
		controller.controller_name == "treatments" ||
		controller.controller_name == "group_classes" ||
		controller.controller_name == "packages" ||
		controller.controller_name == "events" ||
		controller.controller_name == "recurring_events" ||
		controller.controller_name == "event_rsvps" ||
		controller.controller_name == "event_types" ||
		controller.controller_name == "promos"
	end

	def is_admins_others_page?
		controller.controller_name == "testimonials" ||
		controller.controller_name == "items" ||
		controller.controller_name == "purchases" ||
		controller.controller_name == "class_credit_purchases" ||
		controller.controller_name == "questions"
	end

	def is_admins_admins_page?
		controller.controller_name == "admins"
	end

  def is_admins_contact_page?
		controller.controller_name == "inquiries"
	end

	def is_admins_golf_page?
		controller.controller_name == "golf_courses" ||
		controller.controller_name == "golf_business_hours" ||
		controller.controller_name == "golf_rates" ||
		controller.controller_name == "golf_items" ||
		controller.controller_name == "golf_reservations"
	end

end
