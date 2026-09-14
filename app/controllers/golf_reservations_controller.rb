class GolfReservationsController < ApplicationController
  include PaymentReconciliation
  before_action :set_golf_reservation, only: [:show, :add_on, :destroy]
  before_action :verify_access!, only: [:show, :add_on, :destroy]

  def new
    @golf_course = GolfCourse.first
    unless @golf_course
      redirect_to golf_path, alert: "Golf course not available." and return
    end

    @tee_time = params[:tee_time]
    @date     = params[:date]
    @golf_reservation = GolfReservation.new(golf_course: @golf_course)

    if @tee_time.present?
      parsed_tee_time = DateTime.parse(@tee_time) rescue nil
      @remaining = parsed_tee_time ? GolfReservation.remaining_capacity_for(@golf_course, parsed_tee_time) : @golf_course.max_players
    else
      @remaining = @golf_course.max_players
    end
  end

  def create
    @golf_course = GolfCourse.first
    unless @golf_course
      redirect_to golf_path, alert: "Golf course not available." and return
    end

    tee_time_str = params[:tee_time]
    players_count = params[:players_count].to_i
    holes = params[:holes].to_i

    if tee_time_str.blank? || players_count < 1 || holes.zero?
      redirect_to golf_path, alert: "Please select a tee time, number of players, and holes." and return
    end

    tee_time = DateTime.parse(tee_time_str) rescue nil
    unless tee_time
      redirect_to golf_path, alert: "Invalid tee time format." and return
    end

    if tee_time < Time.current
      redirect_to golf_path, alert: "Cannot book a tee time in the past." and return
    end

    if tee_time > 30.days.from_now
      redirect_to golf_path, alert: "Bookings can only be made up to 30 days in advance." and return
    end

    @golf_reservation = GolfReservation.new(
      golf_course: @golf_course,
      user: current_user,
      tee_time: tee_time,
      players_count: players_count,
      holes: holes,
      notes: params[:notes],
      player_names: params[:player_names]&.reject(&:blank?)
    )

    # Capacity is checked and taken under a lock on the course, so two parties cannot both
    # fill the last places of one tee time.
    capacity_message = nil
    saved = GolfReservation.transaction do
      @golf_course.lock!
      if GolfReservation.check_available?(@golf_course, tee_time, players_count)
        @golf_reservation.save
      else
        remaining = GolfReservation.remaining_capacity_for(@golf_course, tee_time)
        capacity_message = remaining.zero? ? "Sorry, that tee time is fully booked." : "Only #{remaining} spot#{'s' unless remaining == 1} remaining for that tee time — please choose a smaller party size or another slot."
        false
      end
    end

    if capacity_message
      redirect_to golf_path, alert: capacity_message
    elsif saved
      track_guest_order!(@golf_reservation)
      redirect_to golf_reservation_path(@golf_reservation.order_id), notice: "Tee time reserved! Please complete payment within #{configatron.payment_window_minutes} minutes."
    else
      redirect_to golf_path, alert: "Unable to create reservation: #{@golf_reservation.errors.full_messages.join(', ')}"
    end
  end

  def show
    if user_signed_in? && @golf_reservation.guest?
      # update_columns: claiming a reservation must not reprice it.
      @golf_reservation.update_columns(user_id: current_user.id, updated_at: Time.current)
      forget_guest_order!(@golf_reservation)
    end

    store_location_for(:user, request.fullpath)

    # A gateway redirect can beat its own webhook back here.
    settle_pending_payment!(@golf_reservation)

    # Same as BookingsController#show: this is the pre-payment page, so once it
    # is paid the owner belongs in My Bookings with the e-ticket modal open.
    if user_signed_in? && @golf_reservation.user_id == current_user.id &&
       @golf_reservation.status == GolfReservation::PAID
      flash.keep # settle_pending_payment! uses flash.now, which a redirect would drop
      return redirect_to users_bookings_path(booking: @golf_reservation.order_id)
    end
  end

  def add_on
    if @golf_reservation.expired? || @golf_reservation.cancelled?
      head :unprocessable_entity and return
    end

    @golf_item = GolfItem.find(params[:golf_item_id])
    if params[:selected] == "true"
      @golf_add_on = GolfAddOn.create(golf_reservation: @golf_reservation, golf_item: @golf_item)
    else
      @golf_add_on = @golf_reservation.golf_add_ons.find_by(golf_item_id: @golf_item.id)
      @golf_add_on&.destroy
    end
    @golf_reservation.save

    respond_to do |format|
      format.js { render :update }
    end
  end

  def destroy
    @golf_reservation.cancel!
    forget_guest_order!(@golf_reservation)
    redirect_to golf_path, alert: "Reservation cancelled."
  end

  private

  def set_golf_reservation
    @golf_reservation = GolfReservation.find_by_order_id(params[:id])
  end

  def verify_access!
    return redirect_to(golf_path, alert: "Reservation not found.") if @golf_reservation.nil?
    return if user_signed_in? && @golf_reservation.user == current_user
    return if user_signed_in? && @golf_reservation.guest?
    return if session_owns?(@golf_reservation)
    redirect_to golf_path, alert: "You don't have access to this reservation."
  end
end
