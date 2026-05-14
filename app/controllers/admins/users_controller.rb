class Admins::UsersController < Admins::BaseController

  def index
    criteria = User.where("full_name LIKE ?", "%#{params[:search]}%")
    @users = criteria.page(params[:page]).per(50)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.js
			format.xls { send_data helpers.generate_users_csv(@users), :filename => "Users-Data.xls" }
    end
  end

	def export_all
		@users = User.all

    respond_to do |format|
			format.xls { send_data helpers.generate_users_csv(@users), :filename => "Users-All.xls" }
    end
	end

  def show
		@user = User.find(params[:id])
		@credit_purchases = @user.class_credit_purchases.includes(:group_class).order(created_at: :desc)
  end

  def edit
		@user = User.find(params[:id])
  end

	def update
		@user = User.find(params[:id])
		if @user.update(params_user)
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
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name, :gender, :phone, :nationality, :dob)
  end

end
