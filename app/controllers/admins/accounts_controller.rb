class Admins::AccountsController < Admins::BaseController

  def change_password
  end

	def update_password
		if current_admin.update(params_admin)
			redirect_to admins_root_path, :notice  => "Successfully change your profile and password."
		else
			flash[:alert] = "Fail to change your profile and password"
			render :action => 'change_password'
		end
	end

  private

  def params_admin
    params.require(:admin).permit(:full_name, :email, :password, :password_confirmation)
  end

end
