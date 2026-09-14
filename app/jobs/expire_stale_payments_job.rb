# Backstop for ExpirePaymentJob, run every minute from config/recurring.yml: expires anything whose
# deadline passed without its own job running (records created before jobs existed, a lost job).
# Slots are already free at the deadline through the `holding` scope; this only settles statuses,
# sends the expiry emails and closes invoices.
class ExpireStalePaymentsJob < ApplicationJob
  queue_as :default

  def perform
    [Booking, GolfReservation, FoodOrder, ClassCreditPurchase].each do |model|
      model.stale_unpaid.unscope(:order).find_each do |record|
        record.expire!
      rescue StandardError => e
        Rails.logger.error("[expire-stale-payments] #{model.name}##{record.id}: #{e.class} #{e.message}")
      end
    end
  end
end
