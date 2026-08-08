class Admins::TreatmentsController < Admins::BaseController
	before_action :set_treatment, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Treatment.all
		else
			criteria = Treatment.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end
		criteria = criteria.where(facility_id: params[:facility_id]) if params[:facility_id].present?

    @treatments = criteria.order(facility_id: :asc, position: :asc).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @treatments }
      format.js
    end
  end

  def new
    @treatment = Treatment.new
  end

  def create
    @treatment = Treatment.new(params_treatment)
    if @treatment.save
			redirect_to admins_treatment_path(@treatment.id), :notice => "Successfully created treatment."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @treatment.update(params_treatment)
			redirect_to admins_treatment_path(@treatment.id), :notice  => "Successfully updated treatment."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @treatment.destroy
    redirect_to admins_treatments_url, :notice => "Successfully destroyed treatment."
  end

  private

  def params_treatment
    params.require(:treatment).permit(:name, :short_description, :duration, :price, :image, :facility_id, :position)
  end

  def set_treatment
		@treatment = Treatment.find(params[:id])
  end
end
