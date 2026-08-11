class Admins::EventTypesController < Admins::BaseController
	before_action :set_event_type, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = EventType.ordered
		else
			criteria = EventType.ordered.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
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

	def delete_banner
		if ActiveStorage::Attachment.find_by(id: params[:asset_id])
			flash[:notice] = "Successfully delete banner."
			@event_type.banner.purge
		end
		redirect_to admins_event_type_path(@event_type.id)
	end

	def delete_image
		if (image = ActiveStorage::Attachment.find_by(id: params[:asset_id]))
			flash[:notice] = "Successfully delete image gallery."
			image.purge
		end
		redirect_to admins_event_type_path(@event_type.id)
	end

	def move_image_up
		@event_type.move_image!(params[:asset_id], -1)
		redirect_to admins_event_type_path(@event_type.id)
	end

	def move_image_down
		@event_type.move_image!(params[:asset_id], 1)
		redirect_to admins_event_type_path(@event_type.id)
	end

  private

  def params_event_type
    params.require(:event_type).permit(:name, :short_description, :description,
																			 :image, :banner, :position, images: [])
  end

  def set_event_type
		@event_type = EventType.find(params[:id])
  end
end
