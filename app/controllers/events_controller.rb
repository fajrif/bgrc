class EventsController < ApplicationController

  def index
    criteria = Event.all
		@events = criteria.page(params[:page]).per(6)

		@meta_title = "Our Events"
		@meta_desc = "events"
  end

  def show
		@event = Event.friendly.find(params[:id])
		@meta_title = @event.name
		@meta_desc = @event.short_description
  end

end
