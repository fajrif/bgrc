class Admins::EventRsvpsController < Admins::BaseController
  before_action :set_rsvp, except: [:index]

  def index
    criteria = EventRsvp.includes(:recurring_event).order(created_at: :desc)
    criteria = criteria.where(recurring_event_id: params[:recurring_event_id]) if params[:recurring_event_id].present?
    @event_rsvps = criteria.page(params[:page]).per(20)
    @recurring_events = RecurringEvent.order(:title)
  end

  def show
  end

  def destroy
    @event_rsvp.destroy
    redirect_to admins_event_rsvps_path, notice: "RSVP deleted."
  end

  private

  def set_rsvp
    @event_rsvp = EventRsvp.find(params[:id])
  end
end
