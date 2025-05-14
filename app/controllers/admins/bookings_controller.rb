class Admins::BookingsController < Admins::BaseController
	before_action :set_courts, except: [:destroy, :send_email_notification]
	before_action :set_booking_object, only: [:show, :edit, :update, :destroy, :send_email_notification]
	include ApplicationHelper

  def index
		if params[:court_id]
			if current_admin.is_admin?
				@court = Court.find(params[:court_id])
			else
				@court = current_admin.courts.find(params[:court_id])
			end
		else
			@court = @courts.first
		end
		@month = params[:month] || Date.today.month
		@year = params[:year] || Date.today.year

		@bookings = @court.bookings.where("cast(strftime('%Y', date) as int) = ? AND cast(strftime('%m', date) as int) = ?", @year, @month)
		@events = JSON[@bookings.map{|b| {title: b.try(:user).try(:email), url: admins_booking_path(b), start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M'), allDay: false, className: "fc-event-book", backgroundColor: colorize(b.try(:user).try(:id)) } }]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookings }
      format.js
			format.xls { send_data Booking.to_csv(@bookings, col_sep: "\t") }
    end
  end

  def show
  end

  def new
    @booking = Booking.new
  end

  def create
		@booking = Booking.new(params_booking)
		if Booking.check_available_dates?(@booking.court.id, @booking.date.strftime("%d/%m/%Y %H:%M"), @booking.duration)
			if @booking.save
				redirect_to admins_booking_path(@booking), :notice => "Successfully created booking."
			else
				render :action => 'new'
			end
		else
			flash[:alert] = "Conflicted schedules please check the calendar first."
			render :action => 'new'
		end
  end

  def edit
  end

  def update
		@booking.assign_attributes(params_booking)
		if Booking.check_available_dates?(@booking.court.id, @booking.date.strftime("%d/%m/%Y %H:%M"), @booking.duration, @booking.id)
			if @booking.save
				redirect_to admins_booking_path(@booking), :notice  => "Successfully updated booking."
			else
				render :action => 'edit'
			end
		else
			flash[:alert] = "Conflicted schedules please check the calendar first."
			render :action => 'edit'
		end
  end

  def destroy
    @booking.destroy
    redirect_to admins_bookings_url, :notice => "Successfully destroyed booking."
  end

	def send_email_notification
    if @booking.send_email_notification!
			redirect_to admins_booking_path(@booking), :notice => "Successfully sent email to #{@booking.user.email} and #{@booking.court.contact_email}."
    else
      render :action => 'show'
    end
	end

  def update_select_duration
		@court = Court.find_by_id(params[:court_id])
    respond_to do |format|
      format.js
    end
  end

  private

  def params_booking
		params.require(:booking).permit(:notes, :date, :end_date, :duration, :status, :user_id, :court_id, :price)
  end

	def set_booking_object
		if current_admin.is_admin?
			@booking = Booking.find(params[:id])
		else
			@booking = current_admin.bookings.find(params[:id])
		end

	end

	def set_courts
		if current_admin.is_admin?
			@courts = Court.unscoped.order(name: :asc)
		else
			@courts = current_admin.courts.order(name: :asc)
		end
	end
end
