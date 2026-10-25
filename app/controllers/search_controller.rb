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
      @schedule = CourtWeekSchedule.new(@court, from: Date.parse(@date))
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
