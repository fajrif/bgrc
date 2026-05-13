class Admins::RecurringEventsController < Admins::BaseController
  before_action :set_recurring_event, except: [:index, :new, :create]

  def index
    criteria = RecurringEvent.all
    if params[:court_id].present?
      criteria = criteria.where(court_id: params[:court_id])
    end
    @recurring_events = criteria.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @recurring_event = RecurringEvent.new
    @courts = Court.all
  end

  def create
    @recurring_event = RecurringEvent.new(params_recurring_event)
    if @recurring_event.save
      redirect_to admins_recurring_event_path(@recurring_event), :notice => "Successfully created recurring event"
    else
      @courts = Court.all
      render :action => 'new'
    end
  end

  def edit
    @courts = Court.all
  end

  def update
    if @recurring_event.update(params_recurring_event)
      redirect_to admins_recurring_event_path(@recurring_event), :notice => "Successfully updated recurring event"
    else
      @courts = Court.all
      render :action => 'edit'
    end
  end

  def destroy
    @recurring_event.destroy
    redirect_to admins_recurring_events_url, :notice => "Successfully destroyed recurring event"
  end

  private

  def params_recurring_event
    params.require(:recurring_event).permit(:title, :court_id, :day_of_week, :specific_date, :start_time, :end_time, :description, :short_description, :capacity, :image, :active)
  end

  def set_recurring_event
    @recurring_event = RecurringEvent.find(params[:id])
  end
end