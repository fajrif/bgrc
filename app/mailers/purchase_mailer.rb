class PurchaseMailer < ApplicationMailer

	def booking_purchase_email
		begin
      @booking = params[:booking]
      @court_type_label = get_court_type(@booking.court_type)
      @user = @booking.user
      mail(
        to: @user.email,
        subject: "BGRC - Purchase Confirmation (#{@booking.order_id}) - #{@booking.created_at.strftime('%d/%m/%Y')}",
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
      @court_type_label = get_court_type(@booking.court_type)
      @user = @booking.user
      mail(
        to: configatron.info_email,
        subject: "BGRC - Booking Confirmation (#{@booking.order_id}) - #{@booking.created_at.strftime('%d/%m/%Y')}",
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
      @court_type_label = get_court_type(@booking.court_type)
      @user = @booking.user
      mail(
        to: @user.email,
        subject: "BGRC - Booking Expired (#{@booking.order_id}) - #{@booking.created_at.strftime('%d/%m/%Y')}",
        template_path: 'purchase_mailer',
        template_name: 'booking_expired_email')
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		end
	end

  private

  def get_court_type(option)
    case option.to_i
    when 0
      "Court Only"
    when 1
      "Court + Coach"
    end
  end

end
