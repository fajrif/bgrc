class Admins::AdminsController < Admins::BaseController
	before_action :set_admin, except: [:index, :new, :create]

  def index
    criteria = Admin.where("full_name ILIKE ? or email ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    @admins = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admins }
      format.js
    end
  end

  def show
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(params_admin)
    if @admin.save
			redirect_to admins_admin_path(@admin), :notice => "Successfully add new admin user."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
		params_admin_save = params_admin
		if params_admin_save[:password].blank?
			params_admin_save = params_admin_save.except(:password, :password_confirmation)
		end
    if @admin.update(params_admin_save)
			redirect_to admins_admin_path(@admin), :notice  => "Successfully updated admin user."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @admin.destroy
    redirect_to admins_admins_url, :notice => "Admin deleted."
  end

  private

	def set_admin
		@admin = Admin.find(params[:id])
	end

  def params_admin
    params.require(:admin).permit(:full_name, :email, :password, :password_confirmation, :role_id)
  end

end
