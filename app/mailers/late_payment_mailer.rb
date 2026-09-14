# Payments that arrived after their hold had lapsed. BBCC does not refund: a booking whose slot was
# taken meanwhile waits for the customer to choose a new time at the price already paid, and a food
# order is made anyway, with staff told if stock ran short.
class LatePaymentMailer < ApplicationMailer
  def self.notify_needs_reschedule(record)
    deliver_safely(with(record: record).needs_reschedule_email)
    deliver_safely(with(record: record).admin_needs_reschedule_email)
  end

  def self.notify_food_needs_attention(food_order)
    deliver_safely(with(food_order: food_order).admin_food_needs_attention_email)
  end

  # A mail failure must never undo the payment it is reporting on.
  def self.deliver_safely(message)
    message.deliver_now
  rescue StandardError => e
    Rails.logger.error("[late-payment-mailer] #{e.class} #{e.message}")
  end
  private_class_method :deliver_safely

  def needs_reschedule_email
    load_record
    mail(to: @user.email, subject: "BGRC - Please choose a new time (#{@order_id})")
  end

  def admin_needs_reschedule_email
    load_record
    mail(to: configatron.info_email, subject: "BGRC - Late payment needs a new time (#{@order_id})")
  end

  def admin_food_needs_attention_email
    @food_order = params[:food_order]
    mail(to: configatron.info_email, subject: "BGRC Grab & Go - Paid order needs attention (#{@food_order.order_id})")
  end

  private

  # One template covers court bookings, tee times and class sessions.
  def load_record
    record = params[:record]
    @user = record.user

    case record
    when Booking
      @kind = "Court booking"
      @order_id = record.order_id
      @description = record.court.try(:name_label) || record.court.try(:name)
      @original_time = record.date
      @amount = record.total_price_label
    when GolfReservation
      @kind = "Tee time"
      @order_id = record.order_id
      @description = "#{record.golf_course.try(:name)} — #{record.players_count} players, #{record.holes_label}"
      @original_time = record.tee_time
      @amount = record.total_price_label
    when GroupClassRegistration
      @kind = "Class session"
      @order_id = record.class_credit_purchase.try(:order_id)
      @description = record.group_class.try(:name)
      @original_time = record.session_date
      @amount = record.class_credit_purchase.try(:price_label)
    end
  end
end
