class Admins::Courts::BusinessHoursController < Admins::BaseController
  before_action :set_court
  before_action :set_business_hour, except: [:index, :new, :create]

  def index
		@business_hours = @court.business_hours.all
  end

  def show
  end

  def new
    @business_hour = BusinessHour.new
    respond_to :js
  end

  def create
		@business_hour = @court.business_hours.build(business_hour_params)
    @business_hour.save
		@business_hours = @court.business_hours
    respond_to :js
  end

  def edit
    respond_to :js
  end

  def update
    @business_hour.update(business_hour_params)
    respond_to :js
  end

  def destroy
    @business_hour.destroy
    respond_to :js
  end

  private

	def set_court
		@court = Court.find(params[:court_id])
	end

	def set_business_hour
		@business_hour = @court.business_hours.find(params[:id])
	end

	def business_hour_params
		params.require(:business_hour).permit(:day_code, :open, :close)
	end

end
