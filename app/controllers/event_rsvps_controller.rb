class EventRsvpsController < ApplicationController
  before_action :set_event

  def create
    @rsvp = @event.event_rsvps.build(rsvp_params)
    if @rsvp.save
      redirect_to event_path(@event), notice: "You have successfully registered! We'll see you there."
    else
      flash.now[:alert] = @rsvp.errors.full_messages.to_sentence
      render "events/show", status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def rsvp_params
    params.require(:event_rsvp).permit(:name, :email, :phone)
  end
end
