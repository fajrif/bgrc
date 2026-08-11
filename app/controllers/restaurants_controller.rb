class RestaurantsController < ApplicationController
  # Three venues were shortened to the names the sitemap uses, and friendly_id
  # regenerated their slugs to match. Their old addresses still resolve.
  RENAMED_SLUGS = {
    "kazumi-azayaka"    => "kasumi",
    "pit-lane-sportsbar" => "pit-lane",
    "portobello"        => "porto"
  }.freeze

  def index
    @banner      = BannerSection.where(name: "Dining").first&.banners&.first
    @restaurants = Restaurant.order(:position)
    @articles    = Article.where(status: 1).first(3)
    @meta_title  = "Dining"
  end

  def show
    if (renamed = RENAMED_SLUGS[params[:id]])
      return redirect_to dining_restaurant_path(renamed), status: :moved_permanently
    end

    @restaurant  = Restaurant.friendly.find(params[:id])
    @restaurants = Restaurant.order(:position)
    @others      = @restaurants.where.not(id: @restaurant.id).limit(3)
    @articles    = Article.where(status: 1).first(3)
    @meta_title  = @restaurant.name
    @meta_desc   = @restaurant.short_description
  end
end
