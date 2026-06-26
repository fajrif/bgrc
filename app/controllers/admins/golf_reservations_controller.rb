class Admins::GolfReservationsController < Admins::BaseController
  before_action :set_golf_reservation, except: [:index, :calendar]

  def index
    criteria = GolfReservation.all
    criteria = criteria.where("order_id ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    criteria = criteria.where(status: params[:status]) if params[:status].present?
    criteria = criteria.where("tee_time::date = ?", Date.parse(params[:date])) if params[:date].present?
    @golf_reservations = criteria.page(params[:page]).per(10)
  end

  def calendar
    @golf_course = GolfCourse.first
    @month = params[:month] || Date.today.month
    @year  = params[:year]  || Date.today.year

    reservations = GolfReservation.unscoped
                                  .where("to_char(tee_time, 'YYYYMM') = ?", "#{@year}#{@month.to_s.rjust(2, '0')}")

    @events = JSON[reservations.map do |r|
      color = case r.status
              when GolfReservation::PAID      then "bg-success"
              when GolfReservation::CANCELLED then "bg-secondary"
              when GolfReservation::EXPIRED   then "bg-secondary"
              else "bg-warning"
              end
      { id: r.id, title: "#{r.order_id} (#{r.players_count}p / #{r.holes}h)",
        start: r.tee_time.strftime('%Y-%m-%dT%H:%M'), allDay: false, className: color,
        url: admins_golf_reservation_path(r) }
    end]
  end

  def show
  end

  def edit
  end

  def update
    if @golf_reservation.update(params_golf_reservation)
      redirect_to admins_golf_reservation_path(@golf_reservation), notice: "Reservation updated."
    else
      render :edit
    end
  end

  def cancel
    unless @golf_reservation.cancelled?
      @golf_reservation.cancel!
    end
    redirect_to admins_golf_reservation_path(@golf_reservation), notice: "Reservation cancelled."
  end

  def mark_paid
    unless @golf_reservation.user.present?
      redirect_to admins_golf_reservation_path(@golf_reservation), alert: "Cannot mark as paid — reservation has no associated user." and return
    end
    @golf_reservation.update!(status: GolfReservation::PAID)
    @golf_reservation.create_purchase_record!
    redirect_to admins_golf_reservation_path(@golf_reservation), notice: "Reservation marked as paid."
  end

  def destroy
    @golf_reservation.destroy
    redirect_to admins_golf_reservations_url, notice: "Reservation deleted."
  end

  private

  def set_golf_reservation
    @golf_reservation = GolfReservation.find(params[:id])
  end

  def params_golf_reservation
    params.require(:golf_reservation).permit(:status, :notes)
  end
end
