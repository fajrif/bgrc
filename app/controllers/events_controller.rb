class EventsController < ApplicationController
  def index
    @events = RecurringEvent.active.includes(:image_attachment).order(id: :desc).page(params[:page]).per(6)
    @meta_title = "Events"
    @meta_desc = "Upcoming events at Bali Beach Country Club"
  end
end
