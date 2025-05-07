class Admins::AddressesController < Admins::BaseController
	before_action :set_address, except: [:index, :new, :create, :sort]

  def index
		@addresses = Address.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @addresses }
      format.js
    end
  end

  def show
  end

  def new
    @address = Address.new
  end

  def create
    @address = Address.new(params_address)
    if @address.save
      redirect_to admins_address_path(@address), :notice => "Successfully created address."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @address.update(params_address)
      redirect_to admins_address_path(@address), :notice  => "Successfully updated address."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @address.destroy
    redirect_to admins_addresses_url, :notice => "Successfully destroyed address."
  end

	def sort
		params[:address].each_with_index do |id, index|
			Address.find(id).update(order_no: index + 1)
		end
		head :ok
	end

  private

  def params_address
    params.require(:address).permit(:order_no, :name, :complete_address, :phone1, :phone2, :fax, :longitude, :latitude, :email1, :email2)
  end

	def set_address
		@address = Address.find(params[:id])
	end

end
