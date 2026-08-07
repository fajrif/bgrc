class Admins::AmenitiesController < Admins::BaseController
	before_action :set_amenity, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Amenity.all
		else
			criteria = Amenity.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

    @amenities = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @amenities }
      format.js
    end
  end

  def new
    @amenity = Amenity.new
  end

  def create
    @amenity = Amenity.new(params_amenity)
    if @amenity.save
			redirect_to admins_amenity_path(@amenity.id), :notice => "Successfully created amenity."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @amenity.update(params_amenity)
			redirect_to admins_amenity_path(@amenity.id), :notice  => "Successfully updated amenity."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @amenity.destroy
    redirect_to admins_amenities_url, :notice => "Successfully destroyed amenity."
  end

  private

  def params_amenity
    params.require(:amenity).permit(:name, :short_description, :image, :facility_id, :position)
  end

  def set_amenity
		@amenity = Amenity.find(params[:id])
  end
end
