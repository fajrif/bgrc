class AjaxSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    user = User.find_for_authentication(email: params[:email])
    if user && user.valid_password?(params[:password])
      sign_in(:user, user)
      render json: { success: true, message: "Signed in successfully." }
    else
      render json: { success: false, message: "Invalid email or password." }, status: :unprocessable_entity
    end
  end
end
