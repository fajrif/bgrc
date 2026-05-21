class WellnessesController < ApplicationController
  before_action :set_banner, only: [:index]

  def index
    @wellnesses = Wellness.all.page(params[:page]).per(12)
    @meta_title = "Wellness"
    @meta_desc  = "Wellness Programs"
  end

  def show
    @wellness = Wellness.friendly.find(params[:id])
    @meta_title = @wellness.name
    @meta_desc  = @wellness.short_description
  end

  private

  def set_banner
    @banner = BannerSection.where(name: "Wellness").first&.banners&.first
  end
end
