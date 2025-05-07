class Admins::BannersController < Admins::BaseController
	before_action :set_banner, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Banner.all
		else
			criteria = Banner.where("title ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

		unless params[:banner_section_id].blank?
			criteria = criteria.where("banner_section_id = ?", "#{params[:banner_section_id]}")
		end
    @banners = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @banners }
      format.js
    end
  end

  def show
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(params_banner)
    if @banner.save
      redirect_to admins_banner_path(@banner), :notice => "Successfully created banner."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @banner.update(params_banner)
      redirect_to admins_banner_path(@banner), :notice  => "Successfully updated banner."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @banner.destroy
    redirect_to admins_banners_url, :notice => "Successfully destroyed banner."
  end

  private

  def params_banner
    params.require(:banner).permit(:order_no, :title, :description, :banner_section_id, :image)
  end

	def set_banner
		@banner = Banner.find(params[:id])
	end

end
