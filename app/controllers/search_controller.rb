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

    @courts = @court_type ? @sport.courts.where(court_type: @court_type.id) : @sport.courts

    unless params[:court_id].blank?
      @court = Court.find(params[:court_id])
    else
      @court = @courts.first
    end

    if @court
      @business_hours = @court.business_hours.map{|bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } }
      @bookings = @court.bookings.where("date >= ? AND status NOT IN (?, ?)", @date, Booking::EXPIRED, Booking::CANCELLED)
      @events = @bookings.map{|b| {title: 'Booked', editable: false, start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M') }}

      @recurring_events = @court.recurring_events.where(active: true)
      @recurring_events.each do |re|
        event_data = {
          title: re.title,
          editable: false,
          selectable: false,
          className: 'recurring-event-block',
          extendedProps: { signUpUrl: Rails.application.routes.url_helpers.recurring_event_path(id: re.id) }
        }
        if re.one_time?
          event_data[:start] = "#{re.specific_date} #{re.start_time}"
          event_data[:end]   = "#{re.specific_date} #{re.end_time}"
        else
          event_data[:daysOfWeek] = [re.day_of_week.to_s]
          event_data[:startTime]  = re.start_time
          event_data[:endTime]    = re.end_time
        end
        @events << event_data
      end

      @court.group_class_schedules.includes(:group_class).each do |gcs|
        color = gcs.group_class.calendar_color.presence || '#0d6efd'
        @events << {
          title: gcs.group_class.name,
          editable: false,
          selectable: false,
          className: 'class-schedule-block',
          backgroundColor: color,
          borderColor: color,
          daysOfWeek: [gcs.day_of_week.to_s],
          startTime: gcs.start_time,
          endTime: gcs.end_time,
          extendedProps: { classUrl: Rails.application.routes.url_helpers.group_class_path(id: gcs.group_class.id) }
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
    if params[:sport_id].blank?
      redirect_to root_path, flash: { warning: "Please select a sport to search." } and return
    end
    @sport = Sport.find(params[:sport_id])
    @pax = params[:pax].presence || 4
  end

end
