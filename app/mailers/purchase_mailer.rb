class PurchaseMailer < ApplicationMailer

	def new_purchase_email
		@purchase = params[:purchase]
		mail(to: @purchase.user.email, from: configatron.company_email, subject: "Purchase - #{@purchase.productable.name}")
	end

	def booking_purchase_email
		begin
      @booking = params[:booking]
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

end
