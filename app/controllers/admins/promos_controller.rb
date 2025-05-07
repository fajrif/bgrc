class Admins::PromosController < Admins::BaseController
	before_action :set_promo, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Promo.all
		else
			criteria = Promo.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

		unless params[:sport_id].blank?
			criteria = criteria.where("sport_id = ?", "#{params[:sport_id]}")
		end
    @promos = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @promos }
      format.js
    end
  end

  def new
    @promo = Promo.new
  end

  def create
    @promo = Promo.new(params_promo)
    if @promo.save
			redirect_to admins_promo_path(@promo.id), :notice => "Successfully created promo."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @promo.update(params_promo)
			redirect_to admins_promo_path(@promo.id), :notice  => "Successfully updated promo."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @promo.destroy
    redirect_to admins_promos_url, :notice => "Successfully destroyed promo."
  end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image."
			@promo.image.purge
		end
		redirect_to admins_promo_path(@promo.id)
	end

  private

  def params_promo
    params.require(:promo).permit(:image, :name, :short_description, :description, :start_date, :end_date, :sport_id, images: [])
  end

  def set_promo
		@promo = Promo.find(params[:id])
  end
end
