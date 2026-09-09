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
      view_start = Date.parse(@date)
      view_end   = view_start + 6.days

      @business_hours = @court.business_hours.map{|bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } }
      @bookings = @court.bookings.where("date >= ? AND status NOT IN (?, ?)", @date, Booking::EXPIRED, Booking::CANCELLED)
      @events = @bookings.map{|b| {title: 'Booked', editable: false, className: 'booking-block', start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M') }}

      @recurring_events = @court.recurring_events.where(active: true)

      # Identify hide+one_time blocking events; add per-day timed blocks
      blocking_events = @recurring_events.select { |re| re.hide? && re.one_time? }
      blocked_slots = []

      blocking_events.each do |re|
        (view_start..view_end).each do |day|
          next unless (re.specific_date..re.effective_end_date).cover?(day)
          blocked_slots << { date: day, start: re.start_time, end: re.end_time }
          @events << {
            title: '', editable: false, selectable: false,
            className: 'recurring-event-block',
            start: "#{day} #{re.start_time}",
            end:   "#{day} #{re.end_time}"
          }
        end
      end

      overlaps_block = ->(date, ev_start, ev_end) {
        blocked_slots.any? do |b|
          b[:date] == date &&
          Time.parse(b[:start]) < Time.parse(ev_end) &&
          Time.parse(b[:end]) > Time.parse(ev_start)
        end
      }

      # Non-blocking recurring events — skip any that time-overlap a blocked slot
      @recurring_events.each do |re|
        next if re.hide? && re.one_time?

        if re.hide?
          event_data = {
            title: '',
            editable: false, selectable: false,
            className: 'recurring-event-block',
          }
        else
          event_data = {
            title: re.title,
            editable: false, selectable: false,
            className: 'recurring-event-visible',
            extendedProps: { signUpUrl: Rails.application.routes.url_helpers.recurring_event_path(id: re.id) }
          }
        end

        if re.one_time?
          (view_start..view_end).each do |day|
            next unless (re.specific_date..re.effective_end_date).cover?(day)
            next if overlaps_block.call(day, re.start_time, re.end_time)
            @events << event_data.merge(start: "#{day} #{re.start_time}", end: "#{day} #{re.end_time}")
          end
        else
          (view_start..view_end).each do |day|
            next unless day.wday == re.day_of_week
            next if overlaps_block.call(day, re.start_time, re.end_time)
            @events << event_data.merge(start: "#{day} #{re.start_time}", end: "#{day} #{re.end_time}")
          end
        end
      end

      # Group class schedules — per-date, skip if time-overlaps a blocked slot
      # (the public calendar is styled by the neutral redesign, so calendar_color
      #  is left to the admin/user calendars that still render it)
      @court.group_class_schedules.includes(:group_class).each do |gcs|
        (view_start..view_end).each do |day|
          next unless day.wday == gcs.day_of_week
          next if overlaps_block.call(day, gcs.start_time, gcs.end_time)
          @events << {
            title: gcs.group_class.name,
            editable: false, selectable: false,
            className: 'class-schedule-block',
            start: "#{day} #{gcs.start_time}",
            end:   "#{day} #{gcs.end_time}",
            extendedProps: { classUrl: Rails.application.routes.url_helpers.group_class_path(id: gcs.group_class.id) }
          }
        end
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
    # /book/racquet-sports is a sitemap URL in its own right, so arriving with no
    # sport picked opens the first racquet sport that actually has courts rather
    # than bouncing back to the homepage. sport_slug comes from the clean
    # /book/tennis, /book/padel, /book/pickleball routes; sport_id is the
    # older query-param path still used by ~40 other call sites.
    @sport = if params[:sport_slug].present?
      Sport.friendly.find(params[:sport_slug])
    elsif params[:sport_id].present?
      Sport.find(params[:sport_id])
    else
      default_racquet_sport
    end
    if @sport.nil?
      redirect_to root_path, flash: { warning: "Please select a sport to search." } and return
    end
    # the homepage hero offers every sport, but golf has no courts to put on the
    # week grid — send it to the tee-time page instead of an empty schedule
    if @sport.golf? && @sport.courts.empty?
      redirect_to golf_path and return
    end
    @pax = params[:pax].presence || 4
  end

  # Golf is booked by tee time, not on the week grid, so it is never the default.
  def default_racquet_sport
    sports = Sport.includes(:courts).order(:id)
    sports.find { |sport| !sport.golf? && sport.courts.any? } || sports.first
  end

end
