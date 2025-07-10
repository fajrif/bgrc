class Admins::SportsController < Admins::BaseController
	before_action :set_sport, except: [:index, :new, :create]

  def index
    criteria = Sport.all
    @sports = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sports }
      format.js
    end
  end

  def new
    @sport = Sport.new
  end

  def create
    @sport = Sport.new(params_sport)
    if @sport.save
			redirect_to admins_sport_path(@sport.id), :notice => "Successfully created sport."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @sport.update(params_sport)
			redirect_to admins_sport_path(@sport.id), :notice  => "Successfully updated sport."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @sport.destroy
    redirect_to admins_sports_url, :notice => "Successfully destroyed sport."
  end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image."
			@sport.image.purge
		end
		redirect_to admins_sport_path(@sport.id)
	end

	def delete_image
		if @image = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image gallery."
      @image.purge
    end
    redirect_to admins_sport_path(@sport.id)
	end

  private

  def params_sport
    params.require(:sport).permit(:image, :name, :short_description, :description, images: [])
  end

  def set_sport
		@sport = Sport.find(params[:id])
  end
end
