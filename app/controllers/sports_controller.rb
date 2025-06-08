class SportsController < ApplicationController

  def show
    @banner = BannerSection.where(name: "Sports").first.banners.first
		@sport = Sport.friendly.find(params[:id])
		@meta_title = @sport.name
		@meta_desc = @sport.short_description
  end

end
