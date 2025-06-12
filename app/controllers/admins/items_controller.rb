class Admins::ItemsController < Admins::BaseController
	before_action :set_item, except: [:index, :new, :create]

  def index
    criteria = Item.where("name ILIKE ?", "%#{params[:search]}%")

    @items = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
      format.js
    end
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(params_item)
    if @item.save
			redirect_to admins_item_path(@item.id), :notice => "Successfully created item."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @item.update(params_item)
			redirect_to admins_item_path(@item.id), :notice  => "Successfully updated item."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @item.destroy
    redirect_to admins_items_url, :notice => "Successfully destroyed item."
  end

  private

  def params_item
    params.require(:item).permit(:name, :price)
  end

  def set_item
		@item = Item.find(params[:id])
  end
end
