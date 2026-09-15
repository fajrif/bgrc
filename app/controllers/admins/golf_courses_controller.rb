class Admins::GolfCoursesController < Admins::BaseController
  before_action :set_golf_course, except: [:index, :new, :create, :sort]

  def index
    @golf_courses = GolfCourse.ordered
    @current_course = GolfCourse.current
  end

  def new
    @golf_course = GolfCourse.new
  end

  def create
    @golf_course = GolfCourse.new(params_golf_course)
    if @golf_course.save
      redirect_to admins_golf_course_path(@golf_course), notice: "Golf course created."
    else
      render :new
    end
  end

  def show
    @golf_business_hours = @golf_course.golf_business_hours
    @golf_rates = @golf_course.golf_rates
    @golf_items = @golf_course.golf_items
  end

  def edit
  end

  def update
    if @golf_course.update(params_golf_course)
      redirect_to admins_golf_course_path(@golf_course), notice: "Golf course updated."
    else
      render :edit
    end
  end

  def destroy
    @golf_course.destroy
    redirect_to admins_golf_courses_url, notice: "Golf course deleted."
  end

  # The drag-and-drop order from the index (jQuery UI sortable). The first active course in this order is
  # the one customers book (GolfCourse.current).
  def sort
    ids = Array(params[:golf_course]).map(&:to_i)
    GolfCourse.transaction do
      ids.each_with_index do |id, index|
        GolfCourse.where(id: id).update_all(position: index + 1, updated_at: Time.current)
      end
    end
    head :ok
  end

  private

  def set_golf_course
    @golf_course = GolfCourse.friendly.find(params[:id])
  end

  def params_golf_course
    params.require(:golf_course).permit(:name, :holes_available, :interval_minutes, :max_players, :location, :status, :image)
  end
end
