module ApplicationHelper

	def is_mobile_request?
		request.user_agent =~ /Mobile|webOS/
	end

	def get_latest_year_options(num=5)
		current_year = Date.today.year
		years = []
		num.times do |n|
			years << current_year - n
		end
		years
	end

	def truncate_text(title, length=30)
		truncate(title, length: length, omission: "...")
  end

	def truncate_paragraph(desc, length=0)
		if length > 0
			truncate(Nokogiri::HTML.parse(desc).css('div')[0].text, length: length, omission: "...")
		else
			Nokogiri::HTML.parse(desc).css('div')[0].text
		end
  end

  def options_select_court
    base = [["Court Only", "court_only"]]
    categories_in_use = GroupClass.available.where.not(category: [nil, ""]).reorder(nil).distinct.pluck(:category)
    category_options = GroupClass::CATEGORIES.select { |_label, slug| categories_in_use.include?(slug) }
                                             .map { |label, slug| [label, slug] }
    base + category_options
  end

  def court_type_is_class?(type)
    type.present? && type != "court_only" && type != "0"
  end

  def options_select_pax(min_pax, max_pax, use_label_min_max=true)
    arr = (min_pax..max_pax)
    arr.map.with_index do |p,i|
      _text = "#{p} pax "
      if use_label_min_max
        if arr.first == arr.last
          _text += "(Maximum)"
        else
          _text += "(Minimum)" if p == arr.first
          _text += "(Maximum)" if p == arr.last
        end
      end
      [_text, p]
    end
  end

  def options_select_class
    [["2 People, Semi Private", 0], ["4 People, Semi Private", 1]]
  end

  def options_select_pax_simple
    (1..4).map { |p| ["#{p} Pax", p] }
  end

  def get_visible_fields(court_type)
    court_type_is_class?(court_type) ? 'display:block;' : 'display:none;'
  end

  def options_for_nationalities
    [
      "Afghan",
      "American",
      "Brazilian",
      "British",
      "Bulgarian",
      "Canadian",
      "Cameroonian",
      "Chinese",
      "Danish",
      "Dutch",
      "Indian",
      "Indonesian"
    ]
  end

	def is_users_account_page?
		controller.controller_name == "accounts"
	end

	def is_users_bookings_page?
		controller.controller_name == "bookings" && controller.action_name != "calendar"
	end

	def is_users_schedule_page?
		controller.controller_name == "bookings" && controller.action_name == "calendar"
	end

	def is_users_packages_page?
		controller.controller_name == "packages"
	end

	def is_users_payment_page?
		controller.controller_name == "payments"
	end

	def productable_type_label(type)
		case type
		when "Booking" then "Booking"
		when "ClassCreditPurchase" then "ClassCredit"
		else type
		end
	end

end
