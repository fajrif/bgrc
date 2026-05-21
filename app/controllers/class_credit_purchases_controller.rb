class ClassCreditPurchasesController < ApplicationController
  before_action :authenticate_user!, only: [:show, :initiate_payment, :payment_callback, :book_session, :claim_session]
  before_action :set_credit_purchase, only: [:show, :initiate_payment, :payment_callback, :book_session, :claim_session]

  def create
    @group_class = GroupClass.find(params.dig(:class_credit_purchase, :group_class_id))
    sessions_count = params.dig(:class_credit_purchase, :sessions_count).to_i
    @initial_session_date = params.dig(:class_credit_purchase, :initial_session_date)

    submitted_pax = params.dig(:class_credit_purchase, :pax).to_i
    submitted_pax = @group_class.min_pax if submitted_pax < @group_class.min_pax

    parsed_initial_date = DateTime.strptime(@initial_session_date, "%d/%m/%Y %H:%M") rescue nil

    if @group_class.is_prescheduled? && parsed_initial_date
      remaining = @group_class.slots_remaining_for(parsed_initial_date.to_date)
      if remaining < submitted_pax
        redirect_to group_class_path(@group_class), alert: "Only #{remaining} slot(s) remaining for #{submitted_pax} pax on that date." and return
      end
    end

    pack = @group_class.group_class_packs.find_by(sessions_count: sessions_count)
    total_price = pack ? pack.price : (@group_class.check_price(submitted_pax, false) * sessions_count)

    @credit_purchase = ClassCreditPurchase.new(
      user: current_user,
      group_class: @group_class,
      sessions_count: sessions_count,
      price_paid: total_price,
      purchase_date: Time.current,
      status: ClassCreditPurchase::PENDING,
      initial_session_date: parsed_initial_date,
      pax: submitted_pax
    )

    if @credit_purchase.save
      session[:credit_purchase_initial_date] = @initial_session_date
      if user_signed_in?
        redirect_to class_credit_purchase_path(@credit_purchase), notice: "Credit purchase created. Please complete your payment."
      else
        store_location_for(:user, class_credit_purchase_path(@credit_purchase))
        redirect_to new_user_session_path, alert: "Please sign in to complete your purchase."
      end
    else
      redirect_to search_path, alert: @credit_purchase.errors.full_messages.to_sentence
    end
  end

  def show
    unless @credit_purchase.user == current_user
      redirect_to root_path, alert: "Access denied."
    end
    @reschedulable_bookings = @credit_purchase.bookings
                                .where(status: Booking::PAID)
                                .where("created_at > ?", 24.hours.ago)
    @registration = @credit_purchase.group_class_registrations.active.first if @credit_purchase.group_class.is_prescheduled?
  end

  def initiate_payment
    begin
      existing = Purchase.find_by(productable: @credit_purchase, user: current_user, status_code: "000")
      existing.destroy if existing
      @purchase = Purchase.new(productable: @credit_purchase, user: current_user, status_code: "000")
      @purchase.save!
      respond_to { |f| f.js }
    rescue => e
      flash.now[:alert] = e.message
      respond_to { |f| f.js { render "initiate_payment_error" } }
    end
  end

  def payment_callback
    @purchase = Purchase.find_or_initialize_by(
      order_id: params[:order_id],
      token: params[:token],
      productable: @credit_purchase,
      user: current_user
    )
    unless @purchase.status_code.in?(["200", "201"])
      if @purchase.save_with_result(params)
        @purchase.process_after_success! if @purchase.status_code == "200"
        flash[:notice] = "Payment successful. Your session credits are now active."
      else
        flash[:alert] = "Payment processing error. Please contact support."
      end
    end
    respond_to { |f| f.js }
  end

  def book_session
    return redirect_to root_path, alert: "Access denied." unless @credit_purchase.user == current_user
    unless @credit_purchase.valid_credit?
      redirect_to class_credit_purchase_path(@credit_purchase),
                  alert: "No sessions remaining or credit is invalid." and return
    end
    if @credit_purchase.group_class.is_prescheduled?
      redirect_to group_class_path(@credit_purchase.group_class),
                  alert: "Prescheduled classes are booked from the class page." and return
    end

    Booking.expire_stale_bookings!

    @group_class = @credit_purchase.group_class
    @sport       = @group_class.sport
    @coaches     = Coach.all
    @date        = params[:date].present? ? Date.parse(params[:date]).strftime("%Y-%m-%d") : Date.today.strftime("%Y-%m-%d")
    @court_types = CourtType.all
    @court_type  = params[:court_type_id].present? ? CourtType.find(params[:court_type_id]) : CourtType.first
    @courts      = @sport.courts.where(court_type: @court_type)
    @court       = params[:court_id].present? ? Court.find(params[:court_id]) : @courts.first

    if @court
      @business_hours = @court.business_hours.map { |bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } }.to_json
      @events = build_claim_calendar_events(@court, @date).to_json
    end

    @selectedDate      = DateTime.parse(@date).to_date
    @selectedDateUntil = @selectedDate + 6.days
    @displayDate       = "#{@selectedDate.strftime('%a %-m/%e/%y')} - #{@selectedDateUntil.strftime('%a %-m/%e/%y')}"

    respond_to do |format|
      format.html
      format.js
    end
  end

  def claim_session
    return redirect_to root_path, alert: "Access denied." unless @credit_purchase.user == current_user
    unless @credit_purchase.valid_credit?
      redirect_to class_credit_purchase_path(@credit_purchase),
                  alert: "No sessions remaining or credit is invalid." and return
    end

    court    = Court.find(params[:court_id])
    coach    = Coach.find(params[:coach_id])
    date_str = params[:dates]
    duration = @credit_purchase.group_class.min_duration

    unless date_str.present? && coach.present? && court.present?
      redirect_to book_session_class_credit_purchase_path(@credit_purchase),
                  alert: "Please select a time slot and coach." and return
    end

    parsed = DateTime.strptime(date_str, "%d/%m/%Y %H:%M") rescue nil
    if parsed.nil?
      redirect_to book_session_class_credit_purchase_path(@credit_purchase),
                  alert: "Invalid date format." and return
    end

    unless Booking.check_available_dates?(court.id, date_str, duration)
      redirect_to book_session_class_credit_purchase_path(@credit_purchase),
                  alert: "Selected slot is no longer available." and return
    end

    @booking = Booking.new(
      user:                  current_user,
      court:                 court,
      coach:                 coach,
      group_class:           @credit_purchase.group_class,
      class_credit_purchase: @credit_purchase,
      date:                  parsed,
      end_date:              parsed + duration.hours,
      duration:              duration,
      pax:                   @credit_purchase.pax,
      court_type:            1,
      status:                Booking::PAID,
      price:                 0,
      price_coach:           0,
      total_price:           0
    )

    if @booking.save
      redirect_to users_bookings_path,
                  notice: "Session claimed for #{parsed.strftime('%a %d %b %Y, %H:%M')}. You can reschedule within 24 hours."
    else
      redirect_to book_session_class_credit_purchase_path(@credit_purchase),
                  alert: @booking.errors.full_messages.to_sentence
    end
  end

  private

  def set_credit_purchase
    @credit_purchase = ClassCreditPurchase.find(params[:id])
  end

  def build_claim_calendar_events(court, date)
    events = []

    court.bookings.where("date >= ? AND status NOT IN (?, ?)", date, Booking::EXPIRED, Booking::CANCELLED).each do |b|
      events << { title: 'Booked', editable: false,
                  start: b.date.strftime('%Y-%m-%d %H:%M'),
                  end:   b.end_date.strftime('%Y-%m-%d %H:%M') }
    end

    court.recurring_events.where(active: true).each do |re|
      event_data = { title: re.title, editable: false, selectable: false,
                     className: 'recurring-event-block',
                     extendedProps: { signUpUrl: recurring_event_path(re) } }
      if re.one_time?
        event_data[:start] = "#{re.specific_date} #{re.start_time}"
        event_data[:end]   = "#{re.specific_date} #{re.end_time}"
      else
        event_data[:daysOfWeek] = [re.day_of_week.to_s]
        event_data[:startTime]  = re.start_time
        event_data[:endTime]    = re.end_time
      end
      events << event_data
    end

    court.group_class_schedules.includes(:group_class).each do |gcs|
      color = gcs.group_class.calendar_color.presence || '#0d6efd'
      events << { title: gcs.group_class.name, editable: false, selectable: false,
                  className: 'class-schedule-block',
                  backgroundColor: color, borderColor: color,
                  daysOfWeek: [gcs.day_of_week.to_s],
                  startTime: gcs.start_time, endTime: gcs.end_time,
                  extendedProps: { classUrl: group_class_path(gcs.group_class) } }
    end

    events
  end
end
