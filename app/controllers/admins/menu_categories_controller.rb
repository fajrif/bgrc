class Admins::MenuCategoriesController < Admins::BaseController
	before_action :set_menu_category, except: [:index, :new, :create]

  def index
		criteria = MenuCategory.all
		criteria = criteria.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%") if params[:search].present?

    @menu_categories = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @menu_categories }
      format.js
    end
  end

  def new
    @menu_category = MenuCategory.new
  end

  def create
    @menu_category = MenuCategory.new(params_menu_category)
    if @menu_category.save
			redirect_to admins_menu_category_path(@menu_category.id), :notice => "Successfully created menu category."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @menu_category.update(params_menu_category)
			redirect_to admins_menu_category_path(@menu_category.id), :notice  => "Successfully updated menu category."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @menu_category.destroy
    redirect_to admins_menu_categories_url, :notice => "Successfully destroyed menu category."
  end

  private

  def params_menu_category
    params.require(:menu_category).permit(:name, :slug, :position)
  end

  def set_menu_category
		@menu_category = MenuCategory.find(params[:id])
  end
end
