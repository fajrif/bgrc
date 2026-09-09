class Admins::CourtsController < Admins::BaseController
  before_action :set_court, except: [:index, :new, :create]
  before_action :set_current_sport, only: [:index, :new, :create]

  def index
    criteria = Court.where("name ILIKE ?", "%#{params[:search]}%")
    criteria = criteria.where(sport_id: @current_sport.id) if @current_sport
    @courts = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courts }
      format.js
    end
  end

  def show
  end

  def new
    @court = Court.new(sport: @current_sport)
  end

  def create
    @court = Court.new(params_court)
    if @court.save
      redirect_to admins_court_path(@court), :notice => "Successfully created court"
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @court.update(params_court)
      redirect_to admins_court_path(@court), :notice  => "Successfully updated court"
    else
      render :action => 'edit'
    end
  end

  def destroy
    @court.destroy
    redirect_to admins_courts_url, :notice => "Successfully destroyed court"
  end

	def delete_image
		@image = ActiveStorage::Attachment.find(params[:id])
		@image.purge
		redirect_to admins_court_path(@court), :notice  => "Delete court image"
	end

  private

  def params_court
    params.require(:court).permit(:name, :status, :sport_id, :min_duration, :instructions, :description, :price, :info, :location, :court_type_id)
  end

  def set_court
		@court = Court.find(params[:id])
  end

  def set_current_sport
    @current_sport = Sport.friendly.find(params[:sport_slug]) if params[:sport_slug].present?
  rescue ActiveRecord::RecordNotFound
    @current_sport = nil
  end

end
