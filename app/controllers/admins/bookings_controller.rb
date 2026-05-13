class Admins::BookingsController < Admins::BaseController
	before_action :set_courts, only: [:calendar]
	before_action :set_booking, except: [:index, :calendar, :new, :create, :cashier_booking, :create_cashier_booking, :check_slot, :export_all]

  def index
    criteria = Booking.where("order_id ILIKE ?", "%#{params[:search]}%")
    @bookings = criteria.page(params[:page]).per(10)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookings }
      format.js
			format.xls { send_data helpers.generate_bookings_csv(@bookings), :filename => "Bookings-Data.xls" }
    end
  end

	def export_all
		@bookings = Booking.all

    respond_to do |format|
			format.xls { send_data helpers.generate_bookings_csv(@bookings), :filename => "Bookings-All.xls" }
    end
	end

  def calendar
		if params[:court_id]
      @court = Court.find(params[:court_id])
		else
			@court = @courts.first
		end

		@month = params[:month] || Date.today.month
		@year = params[:year] || Date.today.year

		@bookings = @court.bookings.where("to_char(date, 'YYYYMM') = ?", "#{@year}#{@month.to_s.rjust(2, '0')}")

    booking_events = @bookings.map do |b|
      color_class = case b.status
                    when Booking::PAID      then "bg-success"
                    when Booking::CANCELLED then "bg-secondary"
                    when Booking::EXPIRED   then "bg-secondary"
                    else "bg-warning"
                    end
      { id: b.id, title: b.order_name_label, url: admins_booking_path(b),
        start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M'),
        allDay: false, className: color_class }
    end

    month_start = Date.new(@year.to_i, @month.to_i, 1)
    recurring_events = @court.recurring_events.map do |re|
      current = month_start
      instances = []
      while current <= month_start.end_of_month
        if current.wday == re.day_of_week
          instances << { title: re.title, start: "#{current.strftime('%Y-%m-%d')}T#{re.start_time}",
                         end: "#{current.strftime('%Y-%m-%d')}T#{re.end_time}",
                         display: "background", className: "bg-danger", allDay: false }
        end
        current += 1.day
      end
      instances
    end.flatten

    @events = JSON[booking_events + recurring_events]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookings }
      format.js
    end
  end

  def check_slot
    court_id = params[:court_id]
    date_str = params[:date]
    duration = params[:duration].to_i

    if court_id.blank? || date_str.blank? || duration < 1
      render json: { available: true, conflicts: [] } and return
    end

    available = Booking::check_available_dates?(court_id, date_str, duration)
    conflicts = []
    unless available
      parsed = DateTime.strptime(date_str, "%d/%m/%Y %H:%M") rescue nil
      if parsed
        slots = duration.times.map { |i| (parsed + i.hours).strftime("%d/%m/%Y %H:%M") }
        existing = Booking.where("court_id = ? AND status NOT IN (?, ?) AND date BETWEEN ? AND ?",
                                 court_id, Booking::EXPIRED, Booking::CANCELLED,
                                 parsed.beginning_of_day, parsed.end_of_day)
        existing.each do |b|
          occupied = b.duration.times.map { |i| (b.date + i.hours).strftime("%d/%m/%Y %H:%M") }
          next if (occupied & slots).empty?
          conflicts << { order_id: b.order_id, user_name: b.try(:user).try(:name) || "Guest",
                         start: b.date.strftime("%d/%m/%Y %H:%M"), duration: b.duration }
        end
      end
    end

    render json: { available: available, conflicts: conflicts }
  end

  def new
    @booking = Booking.new
  end

  def create
    @booking = Booking.new(params_booking)
    if @booking.valid?
      if Booking.check_available_dates?(@booking.court.id, @booking.date.try(:strftime,'%d/%m/%Y %H:%M'), @booking.duration)
        if @booking.save
          redirect_to admins_booking_path(@booking.id), :notice => "Successfully created booking."
        else
          render :action => 'new'
        end
      else
        flash.now[:alert] = 'Booking date not available'
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end

  def cashier_booking
    @booking = Booking.new
    @booking.date = DateTime.parse(params[:date]) rescue nil if params[:date].present?
    @booking.court_id = params[:court_id] if params[:court_id].present?
    @courts = Court.all
    @users = User.all.order(name: :asc)
    @sports = Sport.all
  end

  def create_cashier_booking
    @booking = Booking.new(params_booking)
    @booking.status = Booking::PAID

    if @booking.valid?
      if Booking.check_available_dates?(@booking.court.id, @booking.date.try(:strftime,'%d/%m/%Y %H:%M'), @booking.duration)
        if @booking.save
          @booking.create_purchase_record!
          redirect_to invoice_admins_booking_path(@booking.id), :notice => "Successfully created cashier booking."
        else
          @courts = Court.all
          @users = User.all.order(name: :asc)
          @sports = Sport.all
          render :cashier_booking
        end
      else
        flash.now[:alert] = 'Booking date not available'
        @courts = Court.all
        @users = User.all.order(name: :asc)
        @sports = Sport.all
        render :cashier_booking
      end
    else
      @courts = Court.all
      @users = User.all.order(name: :asc)
      @sports = Sport.all
      render :cashier_booking
    end
  end

  def invoice
    @booking = Booking.find(params[:id])
  end

  def show
  end

  def edit
  end

  def update
    if Booking.check_available_dates?(@booking.court.id, @booking.date.try(:strftime,'%d/%m/%Y %H:%M'), @booking.duration, @booking.id)
      if @booking.update(params_booking)
        redirect_to admins_booking_path(@booking.id), :notice  => "Successfully updated booking."
      else
        render :action => 'edit'
      end
    else
      flash.now[:alert] = 'Booking date not available'
      render :action => 'edit'
    end
  end

  def reschedule
    new_start = DateTime.parse(params[:start]) rescue nil
    new_end   = DateTime.parse(params[:end]) rescue nil

    if new_start.nil? || new_end.nil?
      render json: { error: "Invalid date format." }, status: :unprocessable_entity and return
    end

    duration = ((new_end - new_start) * 24).to_i
    date_str = new_start.strftime("%d/%m/%Y %H:%M")

    unless Booking.check_available_dates?(@booking.court.id, date_str, duration, @booking.id)
      render json: { error: "That time slot is already booked." }, status: :unprocessable_entity and return
    end

    if @booking.update(date: new_start, end_date: new_end, duration: duration)
      render json: { success: true }
    else
      render json: { error: @booking.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def mark_refunded
    @booking.update!(refunded: true)
    redirect_to admins_booking_path(@booking), notice: "Booking marked as refunded."
  end

  def destroy
    @booking.destroy
    redirect_to admins_bookings_url, :notice => "Successfully destroyed booking."
  end

  private

  def params_booking
    params.require(:booking).permit(:user_id, :court_id, :coach_id, :date, :duration, :end_date, :status, :court_type, :class_type, :pax, :group_class_id)
  end

  def set_booking
		@booking = Booking.find(params[:id])
  end

	def set_courts
    @courts = Court.unscoped.order(name: :asc)
	end

end
