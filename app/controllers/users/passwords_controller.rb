class Users::PasswordsController < Users::BaseController

	def edit
		@user = current_user
	end

  def update
    @user = current_user

		if @user.update_attributes(params_user)
			redirect_to users_account_path, :notice => "Successfully change your password."
		else
			flash[:alert] = "Unable to update user. Please complete some required fields."
			render :edit
		end
  end

  private

  def params_user
    params.require(:user).permit(:password, :password_confirmation)
  end
end
