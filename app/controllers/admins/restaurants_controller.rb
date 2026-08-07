class Admins::RestaurantsController < Admins::BaseController
	before_action :set_restaurant, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Restaurant.all
		else
			criteria = Restaurant.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

    @restaurants = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @restaurants }
      format.js
    end
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(params_restaurant)
    if @restaurant.save
			redirect_to admins_restaurant_path(@restaurant.id), :notice => "Successfully created restaurant."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @restaurant.update(params_restaurant)
			redirect_to admins_restaurant_path(@restaurant.id), :notice  => "Successfully updated restaurant."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @restaurant.destroy
    redirect_to admins_restaurants_url, :notice => "Successfully destroyed restaurant."
  end

	def delete_banner
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully deleted banner."
			@restaurant.banner.purge
		end
		redirect_to admins_restaurant_path(@restaurant.id)
	end

	def delete_middle_banner
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully deleted middle banner."
			@restaurant.middle_banner.purge
		end
		redirect_to admins_restaurant_path(@restaurant.id)
	end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully deleted image."
			@restaurant.image.purge
		end
		redirect_to admins_restaurant_path(@restaurant.id)
	end

	def delete_image
		if @image = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully deleted image gallery."
			@image.purge
		end
		redirect_to admins_restaurant_path(@restaurant.id)
	end

  private

  def params_restaurant
    params.require(:restaurant).permit(:banner, :banner_description, :middle_banner, :image, :name,
                                        :short_description, :description, :description1, :description2,
                                        :position, images: [])
  end

  def set_restaurant
		@restaurant = Restaurant.find(params[:id])
  end
end
