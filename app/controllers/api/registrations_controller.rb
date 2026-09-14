module Api
	# The short sign-up in the payment modal: name, email, phone and password. The account starts
	# unconfirmed with its profile marked incomplete (date of birth and nationality come later, from
	# the account page), and a six-digit code is emailed instead of Devise's confirmation link.
	class RegistrationsController < BaseController
		def create
			email = params[:email].to_s.strip.downcase

			if (existing = User.find_by(email: email))
				# An unverified account is not re-sent a code from here: whoever verified would take over an
				# account someone else registered. Signing in proves the password first, then sends the code.
				message = existing.confirmed? ?
					"An account with this email already exists. Please sign in instead." :
					"This email is registered but not verified yet. Sign in with its password to receive a code."
				return render_error(message, status: :conflict)
			end

			user = User.new(
				full_name: params[:full_name].to_s.strip,
				email: email,
				phone: params[:phone].to_s.strip,
				password: params[:password].to_s,
				password_confirmation: params[:password].to_s,
				profile_incomplete: true,
			)
			user.skip_confirmation_notification!
			unless user.save
				return render_error(user.errors.full_messages.to_sentence, errors: user.errors.to_hash(true))
			end

			unless send_code(user)
				return render_error("Your account was created, but we could not send the verification email. Please request a new code.",
				                    status: :service_unavailable, verify: true, email: user.email)
			end

			render json: {
				verify: true,
				email: user.email,
				retry_in: user.verification_resend_wait,
				seconds_remaining: reset_order_window,
			}.compact
		end

		private

		# Registering eats into the payment window, so the order this modal belongs to has its window
		# restarted — once per order, and only for the guest session that created it.
		def reset_order_window
			model = PAYABLE_TYPES[params[:type].to_s] or return nil
			record = model.constantize.unscoped.find_by(order_id: params[:order_id].to_s)
			return nil unless record && record.user_id.nil? && session_owns?(record)
			# Nothing to report when the one-time reset was already used or the window has closed.
			return nil unless record.reset_payment_window_once!

			record.time_remaining
		end
	end
end
