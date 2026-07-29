class Admins::FacilitiesController < Admins::BaseController
	before_action :set_facility, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Facility.all
		else
			criteria = Facility.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end
    @facilities = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @facilities }
      format.js
    end
  end

  def new
    @facility = Facility.new
  end

  def create
    @facility = Facility.new(params_facility)
    if @facility.save
			redirect_to admins_facility_path(@facility.id), :notice => "Successfully created facility."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @facility.update(params_facility)
			redirect_to admins_facility_path(@facility.id), :notice  => "Successfully updated facility."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @facility.destroy
    redirect_to admins_facilities_url, :notice => "Successfully destroyed facility."
  end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image."
			@facility.image.purge
		end
		redirect_to admins_facility_path(@facility.id)
	end

	def delete_image
		if @image = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image gallery."
			@image.purge
		end
		redirect_to admins_facility_path(@facility.id)
	end

  private

  def params_facility
    params.require(:facility).permit(:image, :name, :short_description, :description,
																			:parent_id, :sport_id, :position, :club_life,
																			:cta_label, :cta_url, images: [])
  end

  def set_facility
		@facility = Facility.find(params[:id])
  end
end
