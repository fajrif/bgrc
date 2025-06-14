class CourtsController < ApplicationController

	def calculate_price
		@court = Court.find(params[:id])
		dates = params[:dates]
		duration = params[:duration]
		duration = duration.to_i

    unless params[:court_type].blank?
      @court_type = get_court_type(params[:court_type])
    end

    unless params[:class_type].blank?
      @class_type = get_class_type(params[:class_type])
    end

		price = @court.calculate_price(dates, duration, false)

    unless params[:coach_id].blank?
      if params[:coach_id].to_i > 0
        @coach = Coach.find(params[:coach_id])
        price_coach = @coach.calculate_price(duration, false)
        price = price + price_coach
      end
    end

		@priceLabel = price_label(price)
		priceHuman = price_label(price, true)

		@dates = Time.parse(dates).strftime("%d/%m/%Y %H:%M %p")
		@duration = duration_label(duration)
		@eventTitle = duration > 1 ? "Book #{@duration} #{priceHuman}" : "#{priceHuman}"
		@message = "This court minimum booking for #{@court.min_duration} hours" if duration < @court.min_duration
    respond_to :js
	end

	private

	def duration_label(duration)
		"#{duration} hour".pluralize(duration)
	end

	def price_label(price, humanRead=false)
		if humanRead
			ActionController::Base.helpers.number_to_human(price, :format => 'Rp.%n%u', :units => { :thousand => 'K', :million => 'M' })
		else
			ActionController::Base.helpers.number_to_currency(price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
		end
	end

  def get_court_type(option)
    case option.to_i
    when 0
      "Court Only"
    when 1
      "Court + Coach"
    when 2
      "Group Lessons"
    when 3
      "Adult Socials"
    end
  end

  def get_class_type(option)
    case option.to_i
    when 0
      "2 People, Semi Private"
    when 1
      "4 People, Semi Private"
    end
  end

end
