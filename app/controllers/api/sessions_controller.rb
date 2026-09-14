module Api
	# Sign-in from the payment modal. An account that never confirmed its email gets a six-digit
	# code instead of being turned away, so the guest can finish without leaving the page.
	class SessionsController < BaseController
		def create
			user = User.find_for_authentication(email: params[:email].to_s.strip.downcase)
			unless user&.valid_password?(params[:password].to_s)
				return render_error("Invalid email or password.", status: :unauthorized)
			end

			# Checked before sign_in: Devise's activatable hook would otherwise throw :warden, and the
			# modal would receive an HTML redirect instead of JSON.
			unless user.active_for_authentication?
				if user.confirmed?
					return render_error(I18n.t("devise.failure.#{user.inactive_message}", default: "This account cannot sign in."), status: :forbidden)
				end
				unless send_code(user)
					return render_error("We could not send the verification email. Please try again.", status: :service_unavailable)
				end

				return render json: { verify: true, email: user.email, retry_in: user.verification_resend_wait }
			end

			sign_in(:user, user)
			adopt_guest_orders!(user)
			render json: { success: true }
		end
	end
end
