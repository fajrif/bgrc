class RestaurantsController < ApplicationController
  def index
    @banner      = BannerSection.where(name: "Dining").first&.banners&.first
    @restaurants = Restaurant.order(:position)
    @articles    = Article.where(status: 1).first(3)
    @meta_title  = "Dining"
  end

  def show
    @restaurant  = Restaurant.friendly.find(params[:id])
    @restaurants = Restaurant.order(:position)
    @others      = @restaurants.where.not(id: @restaurant.id).limit(3)
    @articles    = Article.where(status: 1).first(3)
    @meta_title  = @restaurant.name
    @meta_desc   = @restaurant.short_description
  end
end
