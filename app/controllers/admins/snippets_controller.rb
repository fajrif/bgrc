class Admins::SnippetsController < Admins::BaseController
	before_action :set_snippet, except: [:index, :new, :create]

  def index
    criteria = Snippet.where("title ILIKE ?", "%#{params[:search]}%")

    @snippets = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @snippet = Snippet.new
  end

  def create
    @snippet = Snippet.new(params_snippet)
    if @snippet.save
		redirect_to admins_snippet_path(@snippet.id), notice: "Successfully created snippet."
    else
      render action: 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @snippet.update(params_snippet)
		redirect_to admins_snippet_path(@snippet.id), notice: "Successfully updated snippet."
    else
      render action: 'edit'
    end
  end

  def destroy
    @snippet.destroy
    redirect_to admins_snippets_url, notice: "Successfully destroyed snippet."
  end

  private

  def params_snippet
    params.require(:snippet).permit(:key, :title, :content)
  end

  def set_snippet
	@snippet = Snippet.find(params[:id])
  end
end
