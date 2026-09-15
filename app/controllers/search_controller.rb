class SearchController < ApplicationController
  before_action :set_parameter

  # The public court booking page. The calendar, add-ons and pricing live in the Vue component
  # CourtBookingApp (app/frontend/components/booking), which fetches availability and quotes from
  # /api/courts; this action only picks the starting court type, court and week.
  def index
    @date = (Date.parse(params[:date]) rescue nil) || ClubTime.today
    @court_types = CourtType.all
    @court_type = params[:court_type_id].present? ? CourtType.find(params[:court_type_id]) : @court_types.first
    @courts = @court_type ? @sport.courts.where(court_type: @court_type.id) : @sport.courts
    @court = params[:court_id].present? ? Court.find(params[:court_id]) : @courts.first
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
  end

  # Golf is booked by tee time, not on the week grid, so it is never the default.
  def default_racquet_sport
    sports = Sport.includes(:courts).order(:id)
    sports.find { |sport| !sport.golf? && sport.courts.any? } || sports.first
  end

end
