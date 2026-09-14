# Runs once, at an order's payment deadline (scheduled by PaymentWindow). PaymentWindow#expire!
# re-checks the deadline itself, so a job left over from before the deadline was extended does
# nothing — no job ever needs cancelling.
class ExpirePaymentJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(record)
    record.expire!
  end
end
