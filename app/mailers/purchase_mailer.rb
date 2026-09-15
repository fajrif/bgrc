class PurchaseMailer < ApplicationMailer

	def booking_purchase_email
		begin
      @booking = params[:booking]
      @court_type_label = @booking.get_court_type
      @user = @booking.user
      mail(
        to: @user.email,
        subject: "BGRC - Purchase Confirmation (#{@booking.order_id}) - #{booked_on}",
        template_path: 'purchase_mailer',
        template_name: 'booking_purchase_email')
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		end
	end

	def new_booking_email
		begin
      @booking = params[:booking]
      @court_type_label = @booking.get_court_type
      @user = @booking.user
      mail(
        to: configatron.info_email,
        subject: "BGRC - Booking Confirmation (#{@booking.order_id}) - #{booked_on}",
        template_path: 'purchase_mailer',
        template_name: 'new_booking_email')
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		end
	end

	def booking_expired_email
		begin
      @booking = params[:booking]
      @court_type_label = @booking.get_court_type
      @user = @booking.user
      mail(
        to: @user.email,
        subject: "BGRC - Booking Expired (#{@booking.order_id}) - #{booked_on}",
        template_path: 'purchase_mailer',
        template_name: 'booking_expired_email')
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		end
	end

  private

  # The day the booking was made, in club time.
  def booked_on
    ClubTime.local(@booking.created_at).strftime('%d/%m/%Y')
  end

end
