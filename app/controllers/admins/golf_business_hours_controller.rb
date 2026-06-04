class Admins::GolfBusinessHoursController < Admins::BaseController
  before_action :set_golf_course
  before_action :set_golf_business_hour, only: [:edit, :update]

  def edit
  end

  def update
    if @golf_business_hour.update(params_golf_business_hour)
      redirect_to admins_golf_course_path(@golf_course), notice: "Business hours updated."
    else
      render :edit
    end
  end

  private

  def set_golf_course
    if params[:golf_course_id].present?
      @golf_course = GolfCourse.friendly.find(params[:golf_course_id])
    else
      @golf_course = GolfBusinessHour.find(params[:id]).golf_course
    end
  end

  def set_golf_business_hour
    @golf_business_hour = @golf_course.golf_business_hours.find(params[:id])
  end

  def params_golf_business_hour
    params.require(:golf_business_hour).permit(:open, :close, :closed)
  end
end
