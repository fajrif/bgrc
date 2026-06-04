class Admins::GolfRatesController < Admins::BaseController
  before_action :set_golf_course
  before_action :set_golf_rate, only: [:show, :edit, :update, :destroy]

  def index
    @golf_rates = @golf_course.golf_rates
  end

  def new
    @golf_rate = @golf_course.golf_rates.new
  end

  def create
    @golf_rate = @golf_course.golf_rates.new(params_golf_rate)
    if @golf_rate.save
      redirect_to admins_golf_course_path(@golf_course), notice: "Rate created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @golf_rate.update(params_golf_rate)
      redirect_to admins_golf_course_path(@golf_course), notice: "Rate updated."
    else
      render :edit
    end
  end

  def destroy
    @golf_rate.destroy
    redirect_to admins_golf_course_path(@golf_course), notice: "Rate deleted."
  end

  private

  def set_golf_course
    if params[:golf_course_id].present?
      @golf_course = GolfCourse.friendly.find(params[:golf_course_id])
    else
      @golf_course = GolfRate.find(params[:id]).golf_course
    end
  end

  def set_golf_rate
    @golf_rate = @golf_course.golf_rates.find(params[:id])
  end

  def params_golf_rate
    params.require(:golf_rate).permit(:holes, :day_type, :price, :label)
  end
end
