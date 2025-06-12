class Admins::AdultSocialsController < Admins::BaseController
	before_action :set_adult_social, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = AdultSocial.all
		else
			criteria = AdultSocial.where("title ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

		unless params[:sport_id].blank?
			criteria = criteria.where("sport_id = ?", "#{params[:sport_id]}")
		end
    @adult_socials = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @adult_socials }
      format.js
    end
  end

  def new
    @adult_social = AdultSocial.new
  end

  def create
    @adult_social = AdultSocial.new(params_adult_social)
    if @adult_social.save
			redirect_to admins_adult_social_path(@adult_social.id), :notice => "Successfully created adult_social."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @adult_social.update(params_adult_social)
			redirect_to admins_adult_social_path(@adult_social.id), :notice  => "Successfully updated adult_social."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @adult_social.destroy
    redirect_to admins_adult_socials_url, :notice => "Successfully destroyed adult_social."
  end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image."
			@adult_social.image.purge
		end
		redirect_to admins_adult_social_path(@adult_social.id)
	end

  private

  def params_adult_social
    params.require(:adult_social).permit(:title, :short_description, :description, :start_date, :sport_id, :duration, :size, :gender, :invitation_only, :price)
  end

  def set_adult_social
		@adult_social = AdultSocial.find(params[:id])
  end
end
