module Api
	# Places left in a prescheduled class's upcoming sessions, re-read by ClassPurchaseApp when a
	# session fills up while the visitor is deciding.
	class GroupClassesController < BaseController
		def sessions
			group_class = GroupClass.available.find(params[:id])
			render json: { sessions: ClassCreditPurchaseRequest.sessions_for(group_class) }
		end
	end
end
