class Admins::UsersController < Admins::BaseController

  def index
    criteria = User.where("full_name LIKE ?", "%#{params[:search]}%")
    @users = criteria.page(params[:page]).per(50)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.js
			format.xls { send_data User.to_csv(@users, col_sep: "\t") }
    end
  end

  def show
		@user = User.find(params[:id])
  end

  def edit
		@user = User.find(params[:id])
  end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(params_user)
			redirect_to admins_user_path(@user), :notice  => "Successfully updated user."
		else
			render :action => 'edit'
		end
	end

  def destroy
		@user = User.find(params[:id])
    @user.destroy
    redirect_to admins_users_url, :notice => "Successfully destroyed user."
  end

  private

  def params_user
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name, :gender, :mobile_phone)
  end

end
