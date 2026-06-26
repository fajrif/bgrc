class Users::GolfReservationsController < Users::BaseController
  before_action :set_golf_reservation, only: [:destroy]
  before_action :associate_guest_reservations!, only: [:index, :history]

  def index
    GolfReservation.expire_stale_reservations!
    @golf_reservations = current_user.golf_reservations
                                     .where(status: [GolfReservation::UNPAID, GolfReservation::PAID])
                                     .page(params[:page]).per(10)
  end

  def history
    @golf_reservations = current_user.golf_reservations
                                     .where(status: [GolfReservation::EXPIRED, GolfReservation::CANCELLED])
                                     .page(params[:page]).per(10)
  end

  def destroy
    @golf_reservation.cancel!
    redirect_to users_golf_reservations_path, alert: "Reservation cancelled."
  end

  private

  def associate_guest_reservations!
    return unless session[:guest_golf_order_ids].is_a?(Array)
    session[:guest_golf_order_ids].each do |order_id|
      reservation = GolfReservation.find_by(order_id: order_id, user_id: nil)
      reservation&.update(user: current_user)
    end
    session.delete(:guest_golf_order_ids)
  end

  def set_golf_reservation
    @golf_reservation = current_user.golf_reservations.find(params[:id])
  end
end
