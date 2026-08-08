class Admins::FacilityDetailsController < Admins::BaseController
	before_action :set_facility_detail, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = FacilityDetail.all
		else
			criteria = FacilityDetail.where("title ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

    @facility_details = criteria.order(facility_id: :asc, position: :asc).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @facility_details }
      format.js
    end
  end

  def new
    @facility_detail = FacilityDetail.new
  end

  def create
    @facility_detail = FacilityDetail.new(params_facility_detail)
    if @facility_detail.save
			redirect_to admins_facility_detail_path(@facility_detail.id), :notice => "Successfully created info block."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @facility_detail.update(params_facility_detail)
			redirect_to admins_facility_detail_path(@facility_detail.id), :notice  => "Successfully updated info block."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @facility_detail.destroy
    redirect_to admins_facility_details_url, :notice => "Successfully destroyed info block."
  end

  private

  def params_facility_detail
    params.require(:facility_detail).permit(:title, :body, :facility_id, :position)
  end

  def set_facility_detail
		@facility_detail = FacilityDetail.find(params[:id])
  end
end
