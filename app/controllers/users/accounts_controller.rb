class Users::AccountsController < Users::BaseController
  before_action :set_user

  def show
    @user = current_user
		@purchases = current_user.purchases.where(productable_type: "Product", status_code: "200")
  end

  def update
    @user = current_user

		if @user.update(params_user)
			redirect_to users_account_path, :notice => "Successfully update user account."
		else
			flash[:alert] = "Unable to update user. Please complete some required fields."
			render :show
		end
  end

	def delete_photo
		if @asset = ActiveStorage::Attachment.find(params[:asset_id])
			flash[:notice] = "Successfully delete photo."
			@user.photo.purge
		end
		redirect_to users_account_path
	end

  private

  def params_user
    params.require(:user).permit(:email, :full_name, :phone, :dob, :gender, :nationality, :photo)
  end

  def set_user
    @user = current_user
  end

end
