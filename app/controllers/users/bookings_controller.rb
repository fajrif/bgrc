class Users::BookingsController < Users::BaseController

	SPORT_FILTERS = %w[golf racquet].freeze

	before_action :associate_guest_golf_reservations!, only: [:index]

	# "My Bookings" merges court/class bookings and golf reservations into one
	# list. params[:sport] narrows it to just one side; any other/blank value
	# shows both. Two AR relations can't share one SQL pagination, so the
	# combined list is paginated in Ruby via Kaminari.paginate_array.
	def index
		Booking.expire_stale_bookings!
		GolfReservation.expire_stale_reservations!

		sport_filter = params[:sport].to_s if SPORT_FILTERS.include?(params[:sport])

		items = []
		items.concat(current_user.current_bookings.includes(:court, :group_class).to_a) unless sport_filter == "golf"
		unless sport_filter == "racquet"
			items.concat(current_user.golf_reservations
			                         .where(status: [GolfReservation::UNPAID, GolfReservation::PAID])
			                         .includes(:golf_course).to_a)
		end
		items.sort_by!(&:created_at)
		items.reverse!

		@bookings = Kaminari.paginate_array(items).page(params[:page]).per(10)
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
			            backgroundColor: bg, borderColor: br, textColor: tx, allDay: false,
			            extendedProps: {
			              type: "Court Booking",
			              orderId: b.order_id,
			              dateLabel: b.date.strftime("%A, %d %b %Y — %I:%M %p"),
			              subtitleLabel: "Court",
			              subtitle: b.court.try(:name_label),
			              statusLabel: b.status_label,
			              paxLabel: "Pax",
			              pax: b.pax,
			              priceLabel: b.total_price_label,
			              detailUrl: booking_path(b.order_id)
			            } }
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
				allDay: false,
				extendedProps: {
					type: "Group Class",
					orderId: nil,
					dateLabel: reg.session_date.strftime("%A, %d %b %Y — %I:%M %p"),
					subtitleLabel: "Class",
					subtitle: gc.name,
					statusLabel: reg.status_label,
					paxLabel: "Pax",
					pax: reg.pax,
					priceLabel: nil,
					detailUrl: class_credit_purchase_path(reg.class_credit_purchase)
				}
			}
		end

		current_user.golf_reservations
		            .where(status: [GolfReservation::UNPAID, GolfReservation::PAID])
		            .where("tee_time >= ? AND tee_time < ?", start_date, end_date)
		            .includes(:golf_course)
		            .each do |g|
			bg = g.status == GolfReservation::PAID ? "#E9F5FF" : "#ffe8b3"
			br = g.status == GolfReservation::PAID ? "#3AA0FF" : "#d98c00"
			tx = g.status == GolfReservation::PAID ? "#0a4a7a" : "#000"
			estimated_hours = g.holes.to_i <= 9 ? 2 : 4.5
			events << {
				id: "golf-#{g.id}",
				title: "Golf — #{g.golf_course.try(:name) || g.order_id}",
				url: golf_reservation_path(g.order_id),
				start: g.tee_time.strftime('%Y-%m-%dT%H:%M'),
				end: (g.tee_time + estimated_hours.hours).strftime('%Y-%m-%dT%H:%M'),
				backgroundColor: bg, borderColor: br, textColor: tx, allDay: false,
				extendedProps: {
					type: "Golf",
					orderId: g.order_id,
					dateLabel: g.tee_time_label,
					subtitleLabel: "Course",
					subtitle: g.golf_course.try(:name),
					statusLabel: g.status_label,
					paxLabel: "Players",
					pax: g.players_count,
					holesLabel: g.holes_label,
					priceLabel: g.total_price_label,
					detailUrl: golf_reservation_path(g.order_id)
				}
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

  private

  # A guest golf reservation only gets linked to an account once that guest is
  # signed in and lands on a page that claims it. Now that "My Bookings" is
  # the page they land on after login, it needs the same claim logic that
  # Users::GolfReservationsController#index/#history already run.
  def associate_guest_golf_reservations!
    return unless session[:guest_golf_order_ids].is_a?(Array)
    session[:guest_golf_order_ids].each do |order_id|
      reservation = GolfReservation.find_by(order_id: order_id, user_id: nil)
      reservation&.update(user: current_user)
    end
    session.delete(:guest_golf_order_ids)
  end

end
