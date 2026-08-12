class FoodOrderMailer < ApplicationMailer
  def confirmation_email
    @food_order = params[:food_order]
    @user = @food_order.user
    mail(
      to: @user.email,
      subject: "BGRC Grab & Go - Order Confirmed (#{@food_order.order_id})"
    )
  end

  def new_order_email
    @food_order = params[:food_order]
    mail(
      to: configatron.info_email,
      subject: "BGRC Grab & Go - New Order (#{@food_order.order_id})"
    )
  end

  def expired_email
    @food_order = params[:food_order]
    @user = @food_order.user
    mail(
      to: @user.email,
      subject: "BGRC Grab & Go - Order Expired (#{@food_order.order_id})"
    )
  end
end
