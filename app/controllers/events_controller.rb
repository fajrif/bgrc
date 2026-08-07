class EventsController < ApplicationController
  def index
    @banner         = BannerSection.where(name: "Events").first&.banners&.first
    @event_types    = EventType.ordered
    @gallery_images = Event.all.filter_map { |e| e.image if e.image.attached? } +
                       RecurringEvent.active.filter_map { |e| e.image if e.image.attached? }
    @articles       = Article.where(status: 1).first(3)
    @meta_title     = "Events"
    @meta_desc      = "Weddings, corporate events and private celebrations at Bali Beach Country Club"
  end
end
