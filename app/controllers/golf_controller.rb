class GolfController < ApplicationController
  # The tee-time booking page for the bookable course (GolfCourse.current). The tee sheet and reservation
  # form are the Vue component GolfBookingApp (app/frontend/components/golf); the course details and
  # green fees beside it are ERB.
  def index
    @golf_course = GolfCourse.current
  end

  # Feeds the tee sheet: every tee time on a date, with how many places are left. `course_id` asks for a
  # specific course — a late reservation moves on its own course even if another is bookable now.
  def tee_times
    course = GolfCourse.find_by(id: params[:course_id]) if params[:course_id].present?
    course ||= GolfCourse.current
    return render(json: []) if course.nil?

    date = (Date.parse(params[:date].to_s) rescue nil) || ClubTime.today
    slots = course.available_tee_times(date)
    render json: slots.map { |s| { time: s[:time].strftime("%H:%M"), available: s[:available], past: s[:past], remaining: s[:remaining] } }
  end
end
