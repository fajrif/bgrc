class GolfController < ApplicationController
  # The tee-time booking page. The tee sheet and reservation form are the Vue component
  # GolfBookingApp (app/frontend/components/golf); the course details and green fees beside it are ERB.
  def index
    @golf_course = GolfCourse.first
  end

  # Feeds the tee sheet: every tee time on a date, with how many places are left.
  def tee_times
    @golf_course = GolfCourse.first
    if @golf_course.nil?
      render json: [] and return
    end
    date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    slots = @golf_course.available_tee_times(date)
    render json: slots.map { |s| { time: s[:time].strftime("%H:%M"), available: s[:available], past: s[:past], remaining: s[:remaining] } }
  end
end
