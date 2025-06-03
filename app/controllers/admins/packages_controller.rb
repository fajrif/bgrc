class Admins::PackagesController < Admins::BaseController
	before_action :set_package, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Package.all
		else
			criteria = Package.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

		unless params[:sport_id].blank?
			criteria = criteria.where("sport_id = ?", "#{params[:sport_id]}")
		end
    @packages = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @packages }
      format.js
    end
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(params_package)
    if @package.save
			redirect_to admins_package_path(@package.id), :notice => "Successfully created package."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @package.update(params_package)
			redirect_to admins_package_path(@package.id), :notice  => "Successfully updated package."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @package.destroy
    redirect_to admins_packages_url, :notice => "Successfully destroyed package."
  end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image."
			@package.image.purge
		end
		redirect_to admins_package_path(@package.id)
	end

  private

  def params_package
    params.require(:package).permit(:image, :name, :short_description, :description, :start_date, :end_date, :sport_id, images: [])
  end

  def set_package
		@package = Package.find(params[:id])
  end
end
