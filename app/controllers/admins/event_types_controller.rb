class Admins::EventTypesController < Admins::BaseController
	before_action :set_event_type, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = EventType.all
		else
			criteria = EventType.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

    @event_types = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @event_types }
      format.js
    end
  end

  def new
    @event_type = EventType.new
  end

  def create
    @event_type = EventType.new(params_event_type)
    if @event_type.save
			redirect_to admins_event_type_path(@event_type.id), :notice => "Successfully created event type."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @event_type.update(params_event_type)
			redirect_to admins_event_type_path(@event_type.id), :notice  => "Successfully updated event type."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @event_type.destroy
    redirect_to admins_event_types_url, :notice => "Successfully destroyed event type."
  end

  private

  def params_event_type
    params.require(:event_type).permit(:name, :short_description, :image, :position)
  end

  def set_event_type
		@event_type = EventType.find(params[:id])
  end
end
