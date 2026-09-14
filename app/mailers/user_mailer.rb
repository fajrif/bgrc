class UserMailer < ApplicationMailer
  # The code a guest types into the payment modal to verify a new (or unconfirmed) account.
  def verification_code
    @user = params[:user]
    @code = params[:code]
    @minutes = User.verification_code_ttl.in_minutes.to_i
    mail(to: @user.email, subject: "BGRC - Your verification code")
  end
end
