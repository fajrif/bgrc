class Admins::Courts::CostsController < Admins::BaseController
  before_action :set_court
  before_action :set_cost, except: [:index, :new, :create]

  def index
		@costs = @court.costs.all
  end

  def show
  end

  def new
    @cost = Cost.new
    respond_to :js
  end

  def create
		@cost = @court.costs.build(cost_params)
    @cost.save
		@costs = @court.costs
    respond_to :js
  end

  def edit
    respond_to :js
  end

  def update
    @cost.update(cost_params)
    respond_to :js
  end

  def destroy
    @cost.destroy
    respond_to :js
  end

  private

	def set_court
		@court = Court.find(params[:court_id])
	end

	def set_cost
		@cost = @court.costs.find(params[:id])
	end

	def cost_params
		params.require(:cost).permit(:day_code, :start_time, :end_time, :price)
	end

end
