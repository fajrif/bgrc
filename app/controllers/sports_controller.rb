class SportsController < ApplicationController

  def show
		if @sport = Sport.friendly.find(params[:id])
      @banner = BannerSection.where(name: @sport.name).first.banners.first
      @meta_title = @sport.name
      @meta_desc = @sport.short_description
      @group_classes = GroupClass.available.where(sport_id: @sport.id).includes(:group_class_packs)
    end
  end

end
