class EventsController < ApplicationController
  include LocalizedLookup

  before_action :set_banner

  def index
    @event_types    = EventType.ordered
    @gallery_images = Event.all.filter_map { |e| e.image if e.image.attached? } +
                       RecurringEvent.active.filter_map { |e| e.image if e.image.attached? }
    @articles       = Article.where(status: 1).first(3)
    @meta_title     = "Events"
    @meta_desc      = "Weddings, corporate events and private celebrations at Bali Beach Country Club"
  end

  def show
    @event_type = find_by_localized_slug(EventType, params[:id])
    raise ActiveRecord::RecordNotFound if @event_type.nil?

    # reached by the other locale's slug — send the visitor to this locale's
    canonical = event_type_path(@event_type)
    return redirect_to canonical, status: :moved_permanently if request.path != canonical

    @others     = EventType.ordered.where.not(id: @event_type.id)
    @gallery    = @event_type.gallery_images
    @articles   = Article.where(status: 1).first(3)
    @meta_title = @event_type.name
    @meta_desc  = @event_type.short_description
  end

  private

  # An event type with its own banner fronts its page with it; the rest fall
  # back to the shared Events banner.
  def set_banner
    @banner = BannerSection.where(name: "Events").first&.banners&.first
  end
end
