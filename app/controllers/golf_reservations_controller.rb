class GolfReservationsController < ApplicationController
  before_action :set_golf_reservation, only: [:show, :add_on, :destroy, :expire]
  before_action :verify_access!, only: [:show, :add_on, :destroy, :expire]

  def new
    @golf_course = GolfCourse.first
    unless @golf_course
      redirect_to golf_path, alert: "Golf course not available." and return
    end

    @tee_time = params[:tee_time]
    @date     = params[:date]
    @golf_reservation = GolfReservation.new(golf_course: @golf_course)
  end

  def create
    GolfReservation.expire_stale_reservations!

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

    unless GolfReservation.check_available?(@golf_course, tee_time)
      redirect_to golf_path, alert: "Sorry, that tee time is no longer available." and return
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

    if @golf_reservation.save
      session[:guest_golf_order_ids] ||= []
      session[:guest_golf_order_ids] << @golf_reservation.order_id
      redirect_to golf_reservation_path(@golf_reservation.order_id), notice: "Tee time reserved! Please complete payment within 10 minutes."
    else
      redirect_to golf_path, alert: "Unable to create reservation: #{@golf_reservation.errors.full_messages.join(', ')}"
    end
  end

  def show
    if user_signed_in? && @golf_reservation.guest?
      @golf_reservation.update(user: current_user)
    end

    store_location_for(:user, request.fullpath)
    session[:golf_return_url] = request.fullpath
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

  def expire
    if @golf_reservation.is_unpaid?
      @golf_reservation.expire!
    end
    head :ok
  end

  def destroy
    @golf_reservation.cancel!
    session[:guest_golf_order_ids]&.delete(@golf_reservation.order_id)
    redirect_to golf_path, alert: "Reservation cancelled."
  end

  private

  def set_golf_reservation
    @golf_reservation = GolfReservation.find_by_order_id(params[:id])
  end

  def session_owns_reservation?
    session[:guest_golf_order_ids].is_a?(Array) && session[:guest_golf_order_ids].include?(@golf_reservation&.order_id)
  end

  def verify_access!
    return redirect_to(golf_path, alert: "Reservation not found.") if @golf_reservation.nil?
    return if user_signed_in? && @golf_reservation.user == current_user
    return if user_signed_in? && @golf_reservation.guest?
    return if session_owns_reservation?
    redirect_to golf_path, alert: "You don't have access to this reservation."
  end
end
