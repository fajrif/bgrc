class SearchController < ApplicationController
  before_action :set_parameter

  # get public search
  def index
    Booking.expire_stale_bookings!
    @date = Date.today.strftime("%Y-%m-%d")
    unless params[:date].blank?
      @date = Date.parse(params[:date]).strftime("%Y-%m-%d")
    end

    @court_types = CourtType.all
    @court_type = CourtType.first

    unless params[:court_type_id].blank?
      @court_type = CourtType.find(params[:court_type_id])
    end

    @courts = @sport.courts.where(court_type: @court_type.id)

    unless params[:court_id].blank?
      @court = Court.find(params[:court_id])
    else
      @court = @courts.first
    end

    if @court
      @business_hours = @court.business_hours.map{|bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } }
      @bookings = @court.bookings.where("date >= ? AND status NOT IN (?, ?)", @date, Booking::EXPIRED, Booking::CANCELLED)
      @events = @bookings.map{|b| {title: 'Booked', editable: false, start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M') }}

      @recurring_events = @court.recurring_events
      @recurring_events.each do |re|
        @events << {
          title: re.title,
          daysOfWeek: [re.day_of_week.to_s],
          startTime: re.start_time,
          endTime: re.end_time,
          editable: false,
          selectable: false,
          className: 'recurring-event-block'
        }
      end

      @events = @events.to_json
      @business_hours = @business_hours.to_json
    end

    @selectedDate = DateTime.parse(@date).to_date
    @selectedDateUntil = @selectedDate + 6.days
    @displayDate = "#{@selectedDate.strftime('%a %-m/%e/%y')} - #{@selectedDateUntil.strftime('%a %-m/%e/%y')}"

    respond_to do |format|
      format.html
      format.js
    end
  end

  def search_selection
    respond_to do |format|
      format.js
    end
  end

  private

  def set_parameter
    @type = params[:court_type]
    @sport = Sport.find(params[:sport_id])
    unless params[:group_class_id].blank?
      @group_class = GroupClass.find(params[:group_class_id])
      unless params[:pax].blank?
        @pax = params[:pax]
      else
        @pax = @group_class.min_pax
      end
    end
    if @type == "0" || params[:court_type] == "0"
      @pax = params[:pax].presence || @pax
    end
  end

end
