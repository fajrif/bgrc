class CourtsController < ApplicationController

	def calculate_price
		@court = Court.find(params[:id])
		dates = params[:dates]
		duration = params[:duration]
		duration = duration.to_i
		price = @court.calculate_price(dates, duration, false)
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
end
