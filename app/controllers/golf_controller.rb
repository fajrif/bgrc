class GolfController < ApplicationController
  def index
    @golf_course = GolfCourse.first
    if @golf_course
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
      @tee_times = @golf_course.available_tee_times(@selected_date) if request.xhr? == false
    end
  end

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
