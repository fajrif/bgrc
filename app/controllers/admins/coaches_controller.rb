class Admins::CoachesController < Admins::BaseController
	before_action :set_coach, except: [:index, :new, :create]

  def index
    criteria = Coach.where("name ILIKE ?", "%#{params[:search]}%")

    @coaches = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coaches }
      format.js
    end
  end

  def new
    @coach = Coach.new
  end

  def create
    @coach = Coach.new(params_coach)
    if @coach.save
			redirect_to admins_coach_path(@coach.id), :notice => "Successfully created coach."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @coach.update(params_coach)
			redirect_to admins_coach_path(@coach.id), :notice  => "Successfully updated coach."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @coach.destroy
    redirect_to admins_coaches_url, :notice => "Successfully destroyed coach."
  end

  private

  def params_coach
    params.require(:coach).permit(:name, :email, :phone, :gender, :photo)
  end

  def set_coach
		@coach = Coach.find(params[:id])
  end
end
