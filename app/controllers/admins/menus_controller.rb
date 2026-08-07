class Admins::MenusController < Admins::BaseController
	before_action :set_menu, except: [:index, :new, :create]

  def index
		criteria = Menu.all
		criteria = criteria.where(restaurant_id: params[:restaurant_id]) if params[:restaurant_id].present?
		criteria = criteria.where("name ->> :key ILIKE :value", key: I18n.locale.to_s, value: "%#{params[:search]}%") if params[:search].present?

    @menus = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @menus }
      format.js
    end
  end

  def new
    @menu = Menu.new
  end

  def create
    @menu = Menu.new(params_menu)
    if @menu.save
			redirect_to admins_menu_path(@menu.id), :notice => "Successfully created menu."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @menu.update(params_menu)
			redirect_to admins_menu_path(@menu.id), :notice  => "Successfully updated menu."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @menu.destroy
    redirect_to admins_menus_url, :notice => "Successfully destroyed menu."
  end

  private

  def params_menu
    params.require(:menu).permit(:name, :short_description, :image, :restaurant_id, :position)
  end

  def set_menu
		@menu = Menu.find(params[:id])
  end
end
