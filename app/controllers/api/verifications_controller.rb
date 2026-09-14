module Api
	# Checks the six-digit code typed into the payment modal. A correct code confirms the account,
	# signs the guest in and moves this session's orders into it; the page then reloads ready to pay.
	class VerificationsController < BaseController
		def create
			user = User.find_by(email: params[:email].to_s.strip.downcase)
			return render_error("That code has expired. Please request a new one.", status: :gone) if user.nil?

			case user.verify_code!(params[:code])
			when :verified
				sign_in(:user, user)
				adopt_guest_orders!(user)
				render json: { success: true }
			when :invalid
				left = EmailVerificationCode::MAX_ATTEMPTS - user.verification_attempts
				render_error("That code is not right. #{left} #{'attempt'.pluralize(left)} left.")
			when :locked
				render_error("Too many incorrect attempts. Please request a new code.", status: :too_many_requests)
			else
				render_error("That code has expired. Please request a new one.", status: :gone)
			end
		end

		# Answers the same way whether or not the address has an unverified account, so it cannot be
		# used to discover who is registered.
		def resend
			user = User.find_by(email: params[:email].to_s.strip.downcase)

			if user && !user.confirmed?
				wait = user.verification_resend_wait
				if wait.positive?
					return render_error("Please wait #{wait} seconds before requesting another code.", status: :too_many_requests, retry_in: wait)
				end
				unless send_code(user)
					return render_error("We could not send the verification email. Please try again.", status: :service_unavailable)
				end
			end

			render json: { sent: true, retry_in: EmailVerificationCode::RESEND_COOLDOWN.to_i }
		end
	end
end
