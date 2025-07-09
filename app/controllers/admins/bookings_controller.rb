class Admins::BookingsController < Admins::BaseController
	before_action :set_courts, only: [:index]
	before_action :set_booking, only: [:show, :destroy]

  # def index
  #   criteria = Booking.where("order_id ILIKE ?", "%#{params[:search]}%")
  #   @bookings = criteria.page(params[:page]).per(10)
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @bookings }
  #     format.js
	#	    format.xls { send_data Booking.to_csv(@bookings, col_sep: "\t") }
  #   end
  # end

  def index
		if params[:court_id]
      @court = Court.find(params[:court_id])
		else
			@court = @courts.first
		end

		@month = params[:month] || Date.today.month
		@year = params[:year] || Date.today.year

		@bookings = @court.bookings.where("to_char(date, 'YYYYMM') = ?", "#{@year}#{@month.to_s.rjust(2, '0')}")
        #{
            #id: 991,
            #title: 'Repeating Event',
            #start: new Date(y, m, d + 4, 16, 0),
            #end: new Date(y, m, d + 9, 16, 0),
            #allDay: true,
            #className: 'bg-primary-subtle',
            #location: 'Las Vegas, US',
            #extendedProps: {
                #department: 'Repeating Event'
            #},
            #description: 'A recurring or repeating event is simply any event that you will occur more than once on your calendar. ',
        #},

    # binding.pry
    @events = JSON[@bookings.map{|b| {id: b.id, title: b.try(:order_id), url: admins_booking_path(b), start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M'), allDay: false, className: "bg-danger-subtle" } }]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bookings }
      format.js
    end
  end

  def show
  end

  def destroy
    @booking.destroy
    redirect_to admins_bookings_url, :notice => "Successfully destroyed booking."
  end

  private

  def set_booking
		@booking = Booking.find(params[:id])
  end

	def set_courts
    @courts = Court.unscoped.order(name: :asc)
	end

end
