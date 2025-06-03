class PackagesController < ApplicationController
  before_action :set_banner, only: [:index]

  def index
    criteria = Package.all
		@packages = criteria.page(params[:page]).per(6)

		@meta_title = "Our Packages"
		@meta_desc = "packages"
  end

  def show
		@package = Package.friendly.find(params[:id])
		@meta_title = @package.name
		@meta_desc = @package.short_description
  end

  private

  def set_banner
    @banner = BannerSection.where(name: "Packages").first.banners.first
  end
end
