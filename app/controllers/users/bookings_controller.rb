class Users::BookingsController < Users::BaseController

	def index
		Booking.expire_stale_bookings!
		criteria = current_user.current_bookings

		@bookings = criteria.page(params[:page]).per(10)
	end

	def calendar
		Booking.expire_stale_bookings!

		start_date = params[:start].present? ? Date.parse(params[:start]) : Date.today
		end_date   = params[:end].present?   ? Date.parse(params[:end])   : Date.today + 7.days
		events = []

		current_user.bookings
		            .where(status: [Booking::UNPAID, Booking::PAID])
		            .where("date >= ? AND date < ?", start_date, end_date)
		            .includes(:court)
		            .each do |b|
			bg = b.status == Booking::PAID ? "#ECFEED" : "#ffc107"
			br = b.status == Booking::PAID ? "#5BF651" : "#e6a800"
			tx = b.status == Booking::PAID ? "#1a7a1a" : "#000"
			events << { id: b.id, title: b.court.try(:name_label) || b.order_id,
			            url: booking_path(b.order_id),
			            start: b.date.strftime('%Y-%m-%dT%H:%M'),
			            end: b.end_date.strftime('%Y-%m-%dT%H:%M'),
			            backgroundColor: bg, borderColor: br, textColor: tx, allDay: false }
		end

		current_user.group_class_registrations.active
		            .includes(:group_class)
		            .where(session_date: start_date.beginning_of_day..end_date.end_of_day)
		            .each do |reg|
			gc = reg.group_class
			color = gc.calendar_color.presence || '#0d6efd'
			events << {
				id: "reg-#{reg.id}",
				title: gc.name,
				url: class_credit_purchase_path(reg.class_credit_purchase),
				start: reg.session_date.strftime('%Y-%m-%dT%H:%M'),
				end: (reg.session_date + gc.min_duration.hours).strftime('%Y-%m-%dT%H:%M'),
				backgroundColor: color,
				borderColor: color,
				textColor: '#fff',
				allDay: false
			}
		end

		respond_to do |format|
			format.html
			format.json { render json: events }
		end
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

  def return_credit
    @booking = current_user.bookings.find(params[:id])

    unless @booking.class_credit_purchase_id.present?
      redirect_to users_bookings_path, alert: "Not a credit-based booking." and return
    end

    if @booking.created_at < 24.hours.ago
      redirect_to users_bookings_path,
        alert: "Reschedule window has expired. Credit-based bookings can only be cancelled within 24 hours of claiming." and return
    end

    if @booking.status == Booking::CANCELLED
      redirect_to users_bookings_path, alert: "This booking is already cancelled." and return
    end

    @booking.update!(status: Booking::CANCELLED)
    redirect_to users_class_credits_path,
      notice: "Credit returned. You can claim another session for #{@booking.group_class.try(:name)}."
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

    gc = GroupClass.find_by(id: @booking.group_class_id)
    pack = gc&.group_class_packs&.find_by(sessions_count: 1)
    months = pack&.validity_months || gc&.credit_validity_months || configatron.credit_validity_months || 2
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
