class Admins::GroupClassesController < Admins::BaseController
	before_action :set_group_class, except: [:index, :new, :create]

  def index
    @sports = Sport.all
    criteria = GroupClass.all
    criteria = criteria.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    criteria = criteria.where(sport_id: params[:sport_id]) if params[:sport_id].present?
    criteria = criteria.where(category: params[:category]) if params[:category].present?

    @group_classes = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @group_classes }
      format.js
    end
  end

  def new
    @group_class = GroupClass.new
  end

  def create
    @group_class = GroupClass.new(params_group_class)
    if @group_class.save
			redirect_to admins_group_class_path(@group_class), :notice => "Successfully created group class."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @group_class.update(params_group_class)
			redirect_to admins_group_class_path(@group_class), :notice  => "Successfully updated group class."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @group_class.destroy
    redirect_to admins_group_classes_url, :notice => "Successfully destroyed group class."
  end

  private

  def params_group_class
    params.require(:group_class).permit(:name, :min_duration, :min_pax, :max_pax, :status, :price, :price_pax, :notes, :description, :category, :sport_id, :is_prescheduled, :min_pack_sessions, :max_pack_sessions, :calendar_color,
      group_class_packs_attributes: [:id, :sessions_count, :price, :label, :position, :_destroy],
      group_class_schedules_attributes: [:id, :court_id, :day_of_week, :start_time, :end_time, :_destroy])
  end

  def set_group_class
		@group_class = GroupClass.find(params[:id])
  end
end
