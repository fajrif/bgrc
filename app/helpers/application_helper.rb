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
    [["Court Only", 0], ["Court + Coach", 1], ["Group Lessons", 2], ["Adult Socials", 3]]
  end

  def options_select_class
    [["2 People, Semi Private", 0], ["4 People, Semi Private", 1]]
  end

  def get_visible_fields(court_type)
    (court_type == "0" || court_type == "1" || court_type == "2") ? 'display:block;' : 'display:none;'
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
		controller.controller_name == "bookings"
	end

	def is_users_packages_page?
		controller.controller_name == "packages"
	end

	def is_users_payment_page?
		controller.controller_name == "payments"
	end

end
