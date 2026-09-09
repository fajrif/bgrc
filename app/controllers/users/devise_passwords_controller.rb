# Devise's forgot-password flow (request reset email -> set new password).
#
# Distinct from Users::PasswordsController, which is the "change my password
# while already signed in" screen and is not wired into devise_for.
class Users::DevisePasswordsController < Devise::PasswordsController

  # Devise's Recoverable module has no confirmation check, so an unconfirmed
  # user can complete a password reset and then still be refused at sign-in by
  # Confirmable#active_for_authentication?. Completing a reset proves control of
  # the inbox, which is exactly what confirmation asserts, so treat it as one.
  def update
    super do |resource|
      resource.confirm if resource.errors.empty? && !resource.confirmed?
    end
  end
end
