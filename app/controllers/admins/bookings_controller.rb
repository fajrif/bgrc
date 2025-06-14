class Admins::BookingsController < Admins::BaseController
	before_action :set_booking, only: [:show, :destroy]

  def index
    criteria = Booking.where("order_id ILIKE ?", "%#{params[:search]}%")

    @bookings = criteria.page(params[:page]).per(10)

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
end
