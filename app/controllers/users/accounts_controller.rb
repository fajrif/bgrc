class Users::AccountsController < Users::BaseController
	before_action :no_inner_banner

  def show
    @user = current_user
		if @user.address.nil?
			@user.build_address
		end
		@purchases = current_user.purchases.where(productable_type: "Product", status_code: "200")
  end

  def update
    @user = current_user
		if @user.address.nil?
			@user.build_address
		end

		if @user.update_attributes(params_user)
			redirect_to users_account_path, :notice => "Successfully update user account."
		else
			flash[:alert] = "Unable to update user. Please complete some required fields."
			render :show
		end
  end

  private

  def params_user
    params.require(:user).permit(:email, :full_name, :phone, :dob, :gender, address_attributes: [ :id, :country, :address, :province, :city, :district, :village, :zipcode ])
  end

	def no_inner_banner
		@inner_banner = true
	end
end
