class Admins::GolfReservationsController < Admins::BaseController
  before_action :set_golf_reservation, except: [:index, :calendar, :new, :create, :tee_times]

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

  def new
    @golf_reservation = GolfReservation.new
    @golf_courses = GolfCourse.all
    @users = User.all.order(name: :asc)
  end

  def create
    @golf_reservation = GolfReservation.new(params_golf_reservation_create)
    @golf_reservation.status = GolfReservation::PAID
    @golf_courses = GolfCourse.all
    @users = User.all.order(name: :asc)

    if @golf_reservation.valid?
      golf_course = @golf_reservation.golf_course
      if GolfReservation.check_available?(golf_course, @golf_reservation.tee_time, @golf_reservation.players_count)
        if @golf_reservation.save
          @golf_reservation.create_purchase_record! if @golf_reservation.user.present?
          redirect_to admins_golf_reservation_path(@golf_reservation), notice: "Reservation created and marked as paid."
        else
          flash.now[:alert] = @golf_reservation.errors.full_messages.join(", ")
          render :new
        end
      else
        remaining = GolfReservation.remaining_capacity_for(golf_course, @golf_reservation.tee_time)
        flash.now[:alert] = remaining.zero? ? "That tee time is fully booked." : "Only #{remaining} spot#{'s' unless remaining == 1} remaining for that tee time."
        render :new
      end
    else
      flash.now[:alert] = @golf_reservation.errors.full_messages.join(", ")
      render :new
    end
  end

  def tee_times
    golf_course = GolfCourse.find(params[:golf_course_id])
    date = Date.parse(params[:date])
    slots = golf_course.available_tee_times(date)
    render json: slots.map { |s|
      { label: s[:time].strftime("%H:%M"), value: s[:time].strftime("%Y-%m-%dT%H:%M:%S"), available: s[:available], remaining: s[:remaining] }
    }
  rescue
    render json: []
  end

  def show
  end

  def edit
    @golf_courses = GolfCourse.all
    @users = User.all.order(name: :asc)
  end

  def update
    permitted = if @golf_reservation.midtrans_paid?
      params_golf_reservation_safe
    else
      params_golf_reservation_full
    end

    if permitted.key?("tee_time") || permitted.key?("players_count")
      golf_course = permitted[:golf_course_id].present? ? GolfCourse.find(permitted[:golf_course_id]) : @golf_reservation.golf_course
      tee_time = permitted[:tee_time].present? ? (DateTime.parse(permitted[:tee_time]) rescue @golf_reservation.tee_time) : @golf_reservation.tee_time
      players_count = permitted[:players_count].presence&.to_i || @golf_reservation.players_count

      unless GolfReservation.check_available?(golf_course, tee_time, players_count, excluding: @golf_reservation)
        remaining = GolfReservation.remaining_capacity_for(golf_course, tee_time, excluding: @golf_reservation)
        flash.now[:alert] = remaining.zero? ? "That tee time is fully booked." : "Only #{remaining} spot#{'s' unless remaining == 1} remaining for that tee time."
        @golf_courses = GolfCourse.all
        @users = User.all.order(name: :asc)
        render :edit and return
      end
    end

    if @golf_reservation.update(permitted)
      redirect_to admins_golf_reservation_path(@golf_reservation), notice: "Reservation updated."
    else
      @golf_courses = GolfCourse.all
      @users = User.all.order(name: :asc)
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

  def params_golf_reservation_create
    params.require(:golf_reservation).permit(:golf_course_id, :user_id, :tee_time, :players_count, :holes, :notes)
  end

  def params_golf_reservation_safe
    params.require(:golf_reservation).permit(:user_id, :notes)
  end

  def params_golf_reservation_full
    params.require(:golf_reservation).permit(:golf_course_id, :user_id, :tee_time, :players_count, :holes, :notes)
  end
end
