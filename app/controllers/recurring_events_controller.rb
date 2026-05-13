class RecurringEventsController < ApplicationController
  def show
    @recurring_event = RecurringEvent.active.find(params[:id])
    @rsvp = EventRsvp.new
  end

  def rsvp
    @recurring_event = RecurringEvent.active.find(params[:id])
    @rsvp = EventRsvp.new(rsvp_params.merge(recurring_event: @recurring_event))
    if @rsvp.save
      redirect_to recurring_event_path(@recurring_event), notice: "You're registered! We'll see you there."
    else
      render :show
    end
  end

  private

  def rsvp_params
    params.require(:event_rsvp).permit(:full_name, :email, :phone, :dob, :gender, :address)
  end
end
