class Admins::WellnessesController < Admins::BaseController
  before_action :set_wellness, except: [:index, :new, :create]

  def index
    if params[:search].blank?
      criteria = Wellness.all
    else
      criteria = Wellness.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
    end
    @wellnesses = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @wellnesses }
      format.js
    end
  end

  def new
    @wellness = Wellness.new
  end

  def create
    @wellness = Wellness.new(params_wellness)
    if @wellness.save
      redirect_to admins_wellness_path(@wellness.id), notice: "Successfully created wellness."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @wellness.update(params_wellness)
      redirect_to admins_wellness_path(@wellness.id), notice: "Successfully updated wellness."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @wellness.destroy
    redirect_to admins_wellnesses_url, notice: "Successfully destroyed wellness."
  end

  def delete_attachment_image
    if @asset = ActiveStorage::Attachment.find(params[:asset_id])
      flash[:notice] = "Successfully deleted image."
      @wellness.image.purge
    end
    redirect_to admins_wellness_path(@wellness.id)
  end

  private

  def params_wellness
    params.require(:wellness).permit(:image, :name, :short_description, :description, images: [])
  end

  def set_wellness
    @wellness = Wellness.find(params[:id])
  end
end
