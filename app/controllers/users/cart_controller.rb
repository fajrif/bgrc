class Users::CartController < Users::BaseController
	before_action :no_inner_banner

	def show
  end

  def destroy
		@current_cart.destroy
		redirect_to users_cart_path, :notice => "Your cart was empty."
  end

	private

	def no_inner_banner
		@inner_banner = true
	end
end
