class Admins::BookingsController < Admins::BaseController
	before_action :set_courts, only: [:calendar]
	before_action :set_booking, except: [:index, :calendar, :new, :create]

  def index
    criteria = Booking.where("order_id ILIKE ?", "%#{params[:search]}%")
    @bookings = criteria.page(params[:page]).per(10)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookings }
      format.js
	    format.xls { send_data Booking.to_csv(@bookings, col_sep: "\t") }
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
    if @booking.save
			redirect_to admins_booking_path(@booking.id), :notice => "Successfully created booking."
    else
      render :action => 'new'
    end
  end

	# def create
	# 	# Find associated court
	# 	@court = Court.find(params[:court_id])
	# 	dates = params[:dates]
	# 	duration = params[:duration]

	# 	if dates.blank? or duration.blank?
	# 		redirect_to search_path, :alert => "Please select the timetable below and press the submit button."
	# 	else
	# 		if Booking.check_available_dates?(@court.id, dates, duration)
	# 			@booking = Booking.new(court: @court, user: current_user, date: DateTime::strptime(dates,"%d/%m/%Y %H:%M"), duration: duration, court_type: params[:court_type], class_type: params[:class_type], coach_id: params[:coach_id])
	# 			if @booking.save
	# 				# Save and redirect to booking show path
  #         redirect_to users_booking_path(@booking.order_id), :notice => "Court booking added to your booking schedules!"
	# 			else
	# 				redirect_to search_path, :alert => "Oops cannot booking this court!"
	# 			end
	# 		else
	# 			redirect_to search_path, :alert => "Oops sorry booking dates not available"
	# 		end
	# 	end
	# end

  def show
  end

  def edit
  end

  def update
    if @booking.update(params_booking)
			redirect_to admins_booking_path(@booking.id), :notice  => "Successfully updated booking."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @booking.destroy
    redirect_to admins_bookings_url, :notice => "Successfully destroyed booking."
  end

  private

  def params_booking
    params.require(:booking).permit(:user_id, :court_id, :coach_id, :date, :duration, :end_date, :status, :court_type, :class_type)
  end

  def set_booking
		@booking = Booking.find(params[:id])
  end

	def set_courts
    @courts = Court.unscoped.order(name: :asc)
	end

end
