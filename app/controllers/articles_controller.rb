class ArticlesController < ApplicationController

  def index
		@categories = Category.all

		begin
			if @category = Category.find(params[:id])
				criteria = @category.articles
			end
		rescue ActiveRecord::RecordNotFound
			criteria = Article.all
		end

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

end
