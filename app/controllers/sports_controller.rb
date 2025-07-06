class SportsController < ApplicationController

  def show
		if @sport = Sport.friendly.find(params[:id])
      @banner = BannerSection.where(name: @sport.name).first.banners.first
      @meta_title = @sport.name
      @meta_desc = @sport.short_description
    end
  end

end
