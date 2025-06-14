class SearchController < ApplicationController
  before_action :set_others_data

  def index
		# get public home
    unless params[:sport_id].blank?
      @sport = Sport.find(params[:sport_id])
      unless params[:court_id].blank?
        if @court = @sport.courts.find(params[:court_id])
          @business_hours = JSON[@court.business_hours.map{|bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } }]
          @bookings = @court.bookings.where("date >= ?", DateTime.now)
          @events = JSON[@bookings.map{|b| {title: 'Booked', editable: false, start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M') } }]
        end
      end
    end
    unless params[:date].blank?
      @date = Date.parse(params[:date]).strftime("%Y-%m-%d")
    end
  end

  private

  def set_others_data
    @promos = Promo.first(3)
    @articles = Article.first(3)
  end

end
