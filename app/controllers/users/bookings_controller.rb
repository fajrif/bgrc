class Users::BookingsController < Users::BaseController

	def index
		current_user.remove_all_unpaid_bookings
		criteria = current_user.current_bookings

		@bookings = criteria.page(params[:page]).per(10)
	end

	def create
		# Find associated court
		@court = Court.find(params[:court_id])
		dates = params[:dates]
		duration = params[:duration]

		if dates.blank? or duration.blank?
			redirect_to search_path, :alert => "Please select the timetable below and press the submit button."
		else
			if Booking.check_available_dates?(@court.id, dates, duration)
				@booking = Booking.new(court: @court, user: current_user, date: DateTime::strptime(dates,"%d/%m/%Y %H:%M"), duration: duration, court_type: params[:court_type])
        unless params[:group_class_id].blank?
          @booking.group_class_id = params[:group_class_id]
          @booking.pax = params[:pax]
        end
				if @booking.save
					# Save and redirect to booking show path
          redirect_to users_booking_path(@booking.order_id), :notice => "Court booking added to your booking schedules!"
				else
					redirect_to search_path, :alert => "Oops cannot booking this court! please search again."
				end
			else
				redirect_to search_path, :alert => "Oops sorry booking dates not available"
			end
		end
	end

  def show
		@booking = Booking.find_by_order_id(params[:id])
  end

  def add_on
		@booking = Booking.find(params[:id])
    if @item = Item.find(params[:item_id])
      if params["selected"] == "true"
        @add_on = AddOn.create(booking: @booking, item: @item)
      else
        if @add_on = @booking.add_ons.where(item_id: @item.id).first
          @add_on.destroy
        end
      end
      @booking.save
    end

    respond_to do |format|
      format.js  { render :update }
    end
  end

  def add_quantity
		@booking = Booking.find(params[:id])
    if @add_on = @booking.add_ons.find(params[:add_on_id])
      @add_on.quantity += 1
      @add_on.save
      @booking.save
    end

    respond_to do |format|
      format.js  { render :update }
    end
  end

  def remove_quantity
		@booking = Booking.find(params[:id])
    if @add_on = @booking.add_ons.find(params[:add_on_id])
      if @add_on.quantity > 1
        @add_on.quantity -= 1
        @add_on.save
        @booking.save
      end
    end

    respond_to do |format|
      format.js  { render :update }
    end
  end

	def destroy
		@booking = current_user.bookings.find(params[:id])
		@booking.destroy

		redirect_to users_bookings_path, :alert => "Booking canceled."
	end

	def history
		@bookings = current_user.paid_bookings.page(params[:page]).per(10)
	end

end
