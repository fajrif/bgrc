class Admins::CourtsController < Admins::BaseController

  def index
    criteria = Court.where("name LIKE ?", "%#{params[:search]}%")
    @courts = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courts }
      format.js
    end
  end

  def show
		@court = Court.friendly.find(params[:id])
  end

  def new
    @court = Court.new
  end

  def create
    @court = Court.new(params_court)
    if @court.save
      redirect_to admins_court_path(@court), :notice => "Successfully created court."
    else
      render :action => 'new'
    end
  end

  def edit
		@court = Court.friendly.find(params[:id])
  end

  def update
		@court = Court.friendly.find(params[:id])
    if @court.update_attributes(params_court)
      redirect_to admins_court_path(@court), :notice  => "Successfully updated court."
    else
      render :action => 'edit'
    end
  end

  def destroy
		@court = Court.friendly.find(params[:id])
    @court.destroy
    redirect_to admins_courts_url, :notice => "Successfully destroyed court."
  end

	def delete_image
		@court = Court.find(params[:court_id])
		@image = ActiveStorage::Attachment.find(params[:id])
		@image.purge
		redirect_to admins_court_path(@court), :notice  => "Delete court image."
	end

  private

  def params_court
    params.require(:court).permit(:name, :status, :contact_email, :contact_name, :min_duration, :contact_phone, :instructions, :description, :price, :info, :location, :address, :google_maps, :featured, images: [], category_ids: [])
  end

end
