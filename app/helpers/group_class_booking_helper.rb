module GroupClassBookingHelper
	# Props for ClassPurchaseApp (app/frontend/components/classes/ClassPurchaseApp.vue). Every pack and
	# party size is priced here by ClassCreditPurchaseRequest, which also prices the purchase itself.
	def class_purchase_props(group_class)
		packs = ClassCreditPurchaseRequest.pack_options(group_class)
		pax_range = ClassCreditPurchaseRequest.pax_range(group_class)

		{
			groupClass: {
				id: group_class.id,
				name: group_class.name,
				prescheduled: group_class.is_prescheduled?,
				minPax: pax_range.first,
				maxPax: pax_range.last,
			},
			packs: packs,
			# "sessions-pax" => rupiah
			prices: packs.product(pax_range.to_a).to_h do |pack, pax|
				["#{pack[:sessions]}-#{pax}", ClassCreditPurchaseRequest.price_for(group_class, sessions_count: pack[:sessions], pax: pax).to_i]
			end,
			sessions: group_class.is_prescheduled? ? ClassCreditPurchaseRequest.sessions_for(group_class) : [],
			paymentWindowMinutes: configatron.payment_window_minutes,
			urls: {
				purchases: api_class_credit_purchases_path,
				sessions: api_group_class_sessions_path(id: group_class.id),
			},
		}
	end

	# Props for ClassSessionClaimApp. Court URLs carry a __COURT__ placeholder, as on the court booking page.
	def class_session_claim_props(credit_purchase)
		group_class = credit_purchase.group_class
		courts = ClassSessionClaim.courts_for(group_class).to_a

		{
			groupClass: { name: group_class.name, durationHours: group_class.min_duration.to_i, durationLabel: group_class.duration_label },
			pax: credit_purchase.pax || group_class.min_pax,
			courtTypes: CourtType.where(id: courts.map(&:court_type_id).uniq).map { |type| { id: type.id, name: type.name } },
			courts: courts.map { |court| { id: court.id, name: court.name, courtTypeId: court.court_type_id } },
			coaches: ClassSessionClaim.coaches_for(group_class).map { |coach| { id: coach.id, name: coach.name } },
			initialCourtTypeId: courts.first&.court_type_id,
			initialCourtId: courts.first&.id,
			today: ClubTime.today.iso8601,
			maxDate: (ClubTime.today + ClassSessionClaim::HORIZON).iso8601,
			urls: {
				availability: api_court_availability_path(id: "__COURT__"),
				claim: api_class_session_claims_path(id: credit_purchase.id),
			},
		}
	end
end
