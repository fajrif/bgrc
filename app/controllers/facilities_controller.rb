class FacilitiesController < ApplicationController
  before_action :set_banner, only: [:index]

  def index
    criteria = Facility.all
		@facilities = criteria.page(params[:page]).per(6)

		@meta_title = "Our Facilities"
		@meta_desc = "Facilities"
  end

  def show
		@facility = Facility.friendly.find(params[:id])
		@meta_title = @facility.name
		@meta_desc = @facility.short_description
  end

  private

  def set_banner
    @banner = BannerSection.where(name: "Facilities").first.banners.first
  end

end
