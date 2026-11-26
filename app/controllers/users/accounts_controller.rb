class Users::AccountsController < Users::BaseController
  before_action :set_user

  def show
    @user = current_user
  end

  def update
    @user = current_user

		if @user.update(params_user_with_phone)
			redirect_to users_account_path, :notice => "Successfully update user account."
		else
			flash[:alert] = "Unable to update user. Please complete some required fields."
			render :show
		end
  end

  # confirmation screen for the "Log Out" account tab; the sign-out itself
  # stays on Devise's destroy_user_session_path
  def logout
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

  # Phone arrives as a country code plus a local number; the account keeps one value.
  def params_user_with_phone
    attrs = params_user
    if params.dig(:user, :phone).present? || params.dig(:user, :country_code).present?
      attrs[:phone] = User.join_phone(params.dig(:user, :country_code), params.dig(:user, :phone))
    end
    attrs
  end

  def set_user
    @user = current_user
  end

end
