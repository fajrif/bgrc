class Admins::BannerSectionsController < Admins::BaseController
	before_action :set_banner_section, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = BannerSection.all
		else
			criteria = BannerSection.where("name ILIKE ?", "%#{params[:search]}%")
		end
    @banner_sections = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @banner_sections }
      format.js
    end
  end

  def show
  end

  def new
    @banner_section = BannerSection.new
  end

  def create
    @banner_section = BannerSection.new(params_banner_section)
    if @banner_section.save
      redirect_to admins_banner_section_path(@banner_section), :notice => "Successfully created banner section."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @banner_section.update(params_banner_section)
      redirect_to admins_banner_section_path(@banner_section), :notice  => "Successfully updated banner section."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @banner_section.destroy
    redirect_to admins_banner_sections_url, :notice => "Successfully destroyed banner section."
  end

  private

  def params_banner_section
    params.require(:banner_section).permit(:name, :style, :size)
  end

  def set_banner_section
		@banner_section = BannerSection.find(params[:id])
  end

end
