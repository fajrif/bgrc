class ArticlesController < ApplicationController
  before_action :set_banner, only: [:index]

  def index
		@categories = Category.all
		@category = Category.find_by(id: params[:category_id])
		criteria = @category ? @category.articles : Article.all

		unless params[:sort_by].blank?
			criteria = criteria.unscope(:order).order("published_date " + params[:sort_by])
		end

		@articles = criteria.page(params[:page]).per(12)
  end

  def show
		@article = Article.friendly.find(params[:id])
		@category = @article.category
		@meta_title = @article.meta_title unless @article.meta_title.blank?
		@meta_desc = @article.meta_description unless @article.meta_description.blank?
		@articles = Article.most_recent_articles(@article.id, 3)
  end

  private

  def set_banner
    @banner = BannerSection.where(name: "Articles").first.banners.first
  end

end
