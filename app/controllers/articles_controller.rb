class ArticlesController < ApplicationController
	before_action :set_data_page, only: [:index]

  def index
		@categories = Category.all

		begin
			if @category = Category.friendly.find(params[:id])
				criteria = @category.articles
			end
		rescue ActiveRecord::RecordNotFound
			criteria = Article.all
		end

		unless params[:sort_by].blank?
			criteria = criteria.unscope(:order).order("published_date " + params[:sort_by])
		end

		@articles = criteria.page(params[:page]).per(12)

    respond_to do |format|
      format.html {
				@disclosure_informations = ArchiveType.get_disclosure_informations
				render :index
			}
      format.js
    end
  end

  def show
		@article = Article.friendly.find(params[:id])
		@category = @article.category
		@meta_title = @article.meta_title unless @article.meta_title.blank?
		@meta_desc = @article.meta_description unless @article.meta_description.blank?
		@articles = Article.most_recent_articles(@article.id, 3)
  end

	protected

	def set_data_page
		if @page = Page.friendly.find(params[:id])
			@page_news = Page.where("title ->> :key ILIKE :value", key: :en, value: "News").first
			@meta_title = @page.meta_title unless @page.meta_title.blank?
			@meta_desc = @page.meta_description unless @page.meta_description.blank?
			current_banner_section_style(@page.banner_section)
			@banners = @page.banners
		end
	rescue ActiveRecord::RecordNotFound
		puts "No Page Found"
	end

end
