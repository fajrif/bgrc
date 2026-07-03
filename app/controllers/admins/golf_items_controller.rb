class Admins::GolfItemsController < Admins::BaseController
  before_action :set_golf_course
  before_action :set_golf_item, only: [:edit, :update, :destroy]

  def index
    @golf_items = @golf_course.golf_items
  end

  def new
    @golf_item = @golf_course.golf_items.new
  end

  def create
    @golf_item = @golf_course.golf_items.new(params_golf_item)
    if @golf_item.save
      redirect_to admins_golf_course_path(@golf_course), notice: "Add-on item created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @golf_item.update(params_golf_item)
      redirect_to admins_golf_course_path(@golf_course), notice: "Add-on item updated."
    else
      render :edit
    end
  end

  def destroy
    @golf_item.destroy
    redirect_to admins_golf_course_path(@golf_course), notice: "Add-on item deleted."
  end

  private

  def set_golf_course
    if params[:golf_course_id].present?
      @golf_course = GolfCourse.friendly.find(params[:golf_course_id])
    else
      @golf_course = GolfItem.find(params[:id]).golf_course
    end
  end

  def set_golf_item
    @golf_item = @golf_course.golf_items.find(params[:id])
  end

  def params_golf_item
    params.require(:golf_item).permit(:name, :price, :price_type, :status)
  end
end
