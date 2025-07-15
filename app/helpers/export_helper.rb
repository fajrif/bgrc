require 'csv'

module ExportHelper

	def generate_bookings_csv(data, cnt=1, options = { col_sep: "\t" })
		cols = ["ID", "Order ID", "Court", "User", "Email", "Start Date", "End Date", "Duration", "Status", "Total Price"]
		CSV.generate(**options) do |csv|
			csv << cols
			data.each do |b|
				csv << [b.id, b.order_id, b.court.name_label, b.user.full_name, b.user.email, b.date.strftime('%d-%m-%Y %H:%M'), b.end_date.strftime('%d-%m-%Y %H:%M'), b.duration, b.status_label, b.total_price_label]
			end
		end
	end

	def generate_users_csv(data, cnt=1, options = { col_sep: "\t" })
		cols = ["ID", "Name", "Email", "Phone", "Registered At"]
		CSV.generate(**options) do |csv|
			csv << cols
			data.each do |user|
				csv << [user.id, user.full_name, user.email, user.phone.to_s,user.created_at.strftime('%d-%m-%Y %H:%M')]
			end
		end
	end

	def generate_purchases_csv(data, cnt=1, options = { col_sep: "\t" })
		cols = ["ID", "Name", "Email", "Phone", "Gross Amount", "Payment Type", "Status", "Type", "Date"]
		CSV.generate(**options) do |csv|
			csv << cols
			data.each do |purchase|
				csv << [purchase.id, purchase.user.full_name, purchase.user.email, purchase.user.phone.to_s,
						purchase.price_label, purchase.payment_type, "( #{purchase.status_code} ) #{purchase.status_message}",
						purchase.productable_type,
						purchase.created_at.strftime('%d-%m-%Y %H:%M')]
			end
		end
	end

end
