class Admins::HighlightsController < Admins::BaseController
	before_action :set_highlight, except: [:index, :new, :create]

  def index
		if params[:search].blank?
			criteria = Highlight.all
		else
			criteria = Highlight.where("title ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%")
		end

		unless params[:category_id].blank?
			criteria = criteria.where("category_id = ?", "#{params[:category_id]}")
		end
    @highlights = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @highlights }
      format.js
    end
  end

  def new
    @highlight = Highlight.new
  end

  def create
    @highlight = Highlight.new(params_highlight)
    if @highlight.save
			redirect_to admins_highlight_path(@highlight.id), :notice => "Successfully created highlight."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @highlight.update(params_highlight)
			redirect_to admins_highlight_path(@highlight.id), :notice  => "Successfully updated highlight."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @highlight.destroy
    redirect_to admins_highlights_url, :notice => "Successfully destroyed highlight."
  end

	def delete_attachment_image
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete image."
			@highlight.image.purge
		end
		redirect_to admins_highlight_path(@highlight.id)
	end

  private

  def params_highlight
    params.require(:highlight).permit(:image, :title, :short_description, :content, :published_date,
																			:status, :category_id, :meta_title, :meta_description, :tags, :position)
  end

  def set_highlight
		@highlight = Highlight.find(params[:id])
  end
end
