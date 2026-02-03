class Users::PurchasesController < Users::BaseController
	before_action :set_productable

  def new
		begin
			if @productable.is_a?(Booking) && @productable.payment_window_expired?
				flash.now[:alert] = "The time limit for payment has expired."
				respond_to do |format|
					format.js { render :error }
				end
				return
			end

			if request.format.js?
				@purchase = Purchase.find_or_initialize_by(productable: @productable, user: current_user, status_code: "000")
				if @purchase.persisted?
          @purchase.destroy
				end
        @purchase = Purchase.new(productable: @productable, user: current_user, status_code: "000")
        @purchase.save!

				respond_to do |format|
					format.html # new.html.erb
					format.js
				end
			else
				if request.path.include? "product"
					redirect_to product_path(params[:id])
				else
					redirect_to users_bookings_path
				end
			end
		rescue Exception => e
			flash.now[:alert] = e.message
			respond_to do |format|
				format.js  { render :error }
			end
		end
  end

  def create
		@purchase = Purchase.find_or_initialize_by(order_id: params[:order_id], token: params[:token], productable: @productable, user: current_user)

		unless @purchase.status_code == "200" or @purchase.status_code == "201"
			if @purchase.save_with_result(params)
				# Custom
				if @purchase.status_code == "200"
					@purchase.process_after_success!
				end

				flash[:notice] = "Successfully processing payment."
			else
				flash[:alert] = "Some errors were found."
			end
		end

		if @productable.is_a? Booking
			@booking = @purchase.productable
		end

    respond_to do |format|
      format.html # create.html.erb
      format.js
    end
  end

	private

	def set_productable
		@productable = params[:type].to_s.camelize.singularize.constantize.find(params[:id])
	end

end
