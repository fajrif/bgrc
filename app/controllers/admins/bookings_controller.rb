class Admins::BookingsController < Admins::BaseController
	before_action :set_courts, only: [:calendar]
	before_action :set_booking, except: [:index, :calendar, :new, :create, :cashier_booking, :create_cashier_booking]

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
    @events = JSON[@bookings.map{|b| {id: b.id, title: b.order_name_label, url: admins_booking_path(b), start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M'), allDay: false, className: "bg-danger-subtle" } }]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookings }
      format.js
    end
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
