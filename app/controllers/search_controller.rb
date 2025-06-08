class SearchController < ApplicationController

  def index
		# get public home
    if params[:sport]
      @sport = Sport.where('UPPER(name) = ?', params[:sport].upcase).first
      if @court = @sport.courts.first
        @business_hours = JSON[@court.business_hours.map{|bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } }]
        @bookings = @court.bookings.where("date >= ?", DateTime.now)
        @events = JSON[@bookings.map{|b| {title: 'Booked', editable: false, start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M') } }]
      end
    end
    if params[:date]
      @date = Date.parse(params[:date]).strftime("%Y-%m-%d")
    end
  end

end
