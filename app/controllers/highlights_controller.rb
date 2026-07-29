class HighlightsController < ApplicationController
  before_action :set_banner, only: [:index]

  def index
    # get public highlights — the club calendar: socials, clinics and fixtures
    @categories = Category.all
    @category = Category.find_by(id: params[:category_id])
    criteria = Highlight.published
    criteria = criteria.where(category_id: @category.id) if @category
    @highlights = criteria.page(params[:page]).per(12)
  end

  def show
    @highlight = Highlight.friendly.find(params[:id])
    @category = @highlight.category
    @meta_title = @highlight.meta_title.presence || @highlight.title
    @meta_desc = @highlight.meta_description.presence || @highlight.short_description
    @highlights = Highlight.most_recent_highlights(@highlight.id, 3)
    @articles = Article.where(status: 1).first(3)
  end

  private

  def set_banner
    @banner = BannerSection.where(name: "Highlights").first&.banners&.first
  end
end
