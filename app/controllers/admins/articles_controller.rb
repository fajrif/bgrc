class Admins::ArticlesController < Admins::BaseController
	before_action :set_article, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Article.all
		else
			criteria = Article.where("title ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

		unless params[:category_id].blank?
			criteria = criteria.where("category_id = ?", "#{params[:category_id]}")
		end
    @articles = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
      format.js
    end
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(params_article)
    if @article.save
			redirect_to admins_article_path(@article.id), :notice => "Successfully created article."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @article.update(params_article)
			redirect_to admins_article_path(@article.id), :notice  => "Successfully updated article."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @article.destroy
    redirect_to admins_articles_url, :notice => "Successfully destroyed article."
  end

	def delete_attachment
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete attachment."
			@article.file.purge
		end
		redirect_to admins_article_path(@article.id)
	end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image."
			@article.image.purge
		end
		redirect_to admins_article_path(@article.id)
	end

  private

  def params_article
    params.require(:article).permit(:image, :title, :short_description, :content, :published_date, :status, :category_id, :meta_title, :meta_description, :file, :tags)
  end

  def set_article
		@article = Article.find(params[:id])
  end
end
