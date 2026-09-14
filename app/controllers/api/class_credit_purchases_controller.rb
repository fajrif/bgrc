module Api
	# Registers for a group class from the Vue panel on its page (ClassPurchaseApp). The purchase is
	# created unpaid and its page takes payment; guests may buy, and pay after signing in.
	class ClassCreditPurchasesController < BaseController
		def create
			return render_error(purchase_request.errors.full_messages.first) unless purchase_request.valid?

			purchase = purchase_request.purchase!(user: current_user)
			return render_error(ClassCreditPurchaseRequest::FULL_MESSAGE, status: :conflict) if purchase.nil?

			track_guest_order!(purchase) unless user_signed_in?
			render json: { order_id: purchase.order_id, redirect_url: class_credit_purchase_path(id: purchase.id) }, status: :created
		rescue ActiveRecord::RecordInvalid => e
			render_error(e.record.errors.full_messages.to_sentence)
		end

		private

		def purchase_request
			@purchase_request ||= ClassCreditPurchaseRequest.new(
				group_class: GroupClass.available.find(params[:group_class_id]),
				sessions_count: params[:sessions_count],
				pax: params[:pax],
				session_start: params[:session_start],
			)
		end
	end
end
