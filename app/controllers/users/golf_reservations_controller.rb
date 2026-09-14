class Users::GolfReservationsController < Users::BaseController
  before_action :set_golf_reservation, only: [:destroy]
  before_action -> { adopt_guest_orders!(current_user) }, only: [:index, :history]

  def index
    @golf_reservations = current_user.golf_reservations
                                     .holding_or_rescheduling
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

  def set_golf_reservation
    @golf_reservation = current_user.golf_reservations.find(params[:id])
  end
end
