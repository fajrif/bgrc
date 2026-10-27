class SubscribersController < ApplicationController
  # The "Join the club" band in the footer. `website` is a honeypot: real
  # visitors never see it, so a filled value means a bot and is silently ignored.
  def create
    if params[:website].present?
      flash[:notice] = "Thank you for subscribing."
    else
      subscriber = Subscriber.new(email: params.dig(:subscriber, :email))
      if subscriber.save
        flash[:notice] = "Thank you for subscribing."
      elsif subscriber.errors.of_kind?(:email, :taken)
        flash[:notice] = "You are already subscribed."
      else
        flash[:alert] = "Please enter a valid email address."
      end
    end
    redirect_back fallback_location: root_path
  end
end
