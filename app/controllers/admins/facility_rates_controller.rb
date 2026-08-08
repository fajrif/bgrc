class Admins::FacilityRatesController < Admins::BaseController
	before_action :set_facility_rate, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = FacilityRate.all
		else
			criteria = FacilityRate.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

    @facility_rates = criteria.order(facility_id: :asc, position: :asc).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @facility_rates }
      format.js
    end
  end

  def new
    @facility_rate = FacilityRate.new
  end

  def create
    @facility_rate = FacilityRate.new(params_facility_rate)
    if @facility_rate.save
			redirect_to admins_facility_rate_path(@facility_rate.id), :notice => "Successfully created rate."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @facility_rate.update(params_facility_rate)
			redirect_to admins_facility_rate_path(@facility_rate.id), :notice  => "Successfully updated rate."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @facility_rate.destroy
    redirect_to admins_facility_rates_url, :notice => "Successfully destroyed rate."
  end

  private

  def params_facility_rate
    params.require(:facility_rate).permit(:name, :time, :access, :price, :facility_id, :position)
  end

  def set_facility_rate
		@facility_rate = FacilityRate.find(params[:id])
  end
end
