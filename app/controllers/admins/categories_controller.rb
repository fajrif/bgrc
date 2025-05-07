class Admins::CategoriesController < Admins::BaseController
	before_action :set_category, except: [:index, :new, :create]

  def index
    criteria = Category.all
    @categories = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
      format.js
    end
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params_category)
    if @category.save
			redirect_to admins_category_path(@category.id), :notice => "Successfully created category."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @category.update(params_category)
			redirect_to admins_category_path(@category.id), :notice  => "Successfully updated category."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @category.destroy
    redirect_to admins_categories_url, :notice => "Successfully destroyed category."
  end

  private

  def params_category
    params.require(:category).permit(:name)
  end

	def set_category
		@category = Category.find(params[:id])
	end
end
