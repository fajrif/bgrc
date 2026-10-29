class Admins::FacilityBenefitsController < Admins::BaseController
	before_action :set_facility_benefit, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = FacilityBenefit.all
		else
			criteria = FacilityBenefit.where("title ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

    @facility_benefits = criteria.order(facility_id: :asc, position: :asc).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @facility_benefits }
      format.js
    end
  end

  def new
    @facility_benefit = FacilityBenefit.new
  end

  def create
    @facility_benefit = FacilityBenefit.new(params_facility_benefit)
    if @facility_benefit.save
			redirect_to admins_facility_benefit_path(@facility_benefit.id), :notice => "Successfully created benefit."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @facility_benefit.update(params_facility_benefit)
			redirect_to admins_facility_benefit_path(@facility_benefit.id), :notice  => "Successfully updated benefit."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @facility_benefit.destroy
    redirect_to admins_facility_benefits_url, :notice => "Successfully destroyed benefit."
  end

  private

  def params_facility_benefit
    params.require(:facility_benefit).permit(:title, :description, :facility_id, :position, :icon)
  end

  def set_facility_benefit
		@facility_benefit = FacilityBenefit.find(params[:id])
  end
end
