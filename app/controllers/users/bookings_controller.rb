class Users::BookingsController < Users::BaseController

	def index
		Booking.expire_stale_bookings!
		criteria = current_user.current_bookings

		@bookings = criteria.page(params[:page]).per(10)
	end

	def calendar
		Booking.expire_stale_bookings!
		bookings = current_user.bookings.where(status: [Booking::UNPAID, Booking::PAID])
		                                .where("date >= ?", Time.current)
		@events = bookings.map do |b|
			color = b.status == Booking::PAID ? "#198754" : "#ffc107"
			{ id: b.id, title: b.court.try(:name_label) || b.order_id,
				url: booking_path(b.order_id),
				start: b.date.strftime('%Y-%m-%dT%H:%M'),
				end: b.end_date.strftime('%Y-%m-%dT%H:%M'),
				color: color, allDay: false }
		end.to_json
	end

	def destroy
		@booking = current_user.bookings.find(params[:id])
		@booking.cancel!

		redirect_to users_bookings_path, alert: "Booking cancelled."
	end

	def history
		Booking.expire_stale_bookings!
		@bookings = current_user.booking_history.page(params[:page]).per(10)
	end

  def reschedule_to_credit
    @booking = current_user.bookings.find(params[:id])

    unless @booking.status == Booking::PAID && @booking.group_class_id.present?
      redirect_to users_bookings_path, alert: "This booking cannot be rescheduled." and return
    end

    hours_remaining = (@booking.date - Time.current) / 1.hour
    unless hours_remaining.between?(12, 24)
      redirect_to users_bookings_path,
        alert: "Reschedule is only available between 12 and 24 hours before the session." and return
    end

    max_reschedules = configatron.max_reschedule_count || 2
    if @booking.reschedule_count >= max_reschedules
      redirect_to users_bookings_path,
        alert: "You have reached the maximum number of reschedules for this booking." and return
    end

    months = configatron.credit_validity_months || 2
    if @booking.class_credit_purchase.present?
      @booking.update!(status: Booking::CANCELLED, reschedule_count: @booking.reschedule_count + 1)
    else
      credit = ClassCreditPurchase.create!(
        user: current_user,
        group_class_id: @booking.group_class_id,
        sessions_count: 1,
        price_paid: 0,
        status: ClassCreditPurchase::PAID,
        expires_at: months.months.from_now
      )
      @booking.update!(status: Booking::CANCELLED, class_credit_purchase: credit,
                       reschedule_count: @booking.reschedule_count + 1)
    end

    redirect_to users_class_credits_path,
      notice: "Session converted to 1 credit. Book a new session from the search page."
  end

end
