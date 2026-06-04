class GolfReservationMailer < ApplicationMailer
  def confirmation_email
    @golf_reservation = params[:golf_reservation]
    @user = @golf_reservation.user
    mail(
      to: @user.email,
      subject: "BGRC Golf - Booking Confirmed (#{@golf_reservation.order_id})"
    )
  end

  def new_reservation_email
    @golf_reservation = params[:golf_reservation]
    mail(
      to: configatron.info_email,
      subject: "BGRC Golf - New Reservation (#{@golf_reservation.order_id})"
    )
  end

  def expired_email
    @golf_reservation = params[:golf_reservation]
    @user = @golf_reservation.user
    mail(
      to: @user.email,
      subject: "BGRC Golf - Reservation Expired (#{@golf_reservation.order_id})"
    )
  end
end
