# A purchasable record that holds something — a court slot, a tee time, a class place — while its
# owner pays. The deadline comes from the database clock and is enforced three ways:
#
#   * availability queries use `holding`, so a lapsed hold frees its slot at the deadline, to the
#     second, whether or not anything has run yet;
#   * ExpirePaymentJob runs at the deadline to mark the record EXPIRED and close its invoice;
#   * ExpireStalePaymentsJob sweeps every minute in case a job was lost.
#
# Including models define UNPAID, PAID and EXPIRED, plus `is_unpaid?` and `expired?`.
module PaymentWindow
  extend ActiveSupport::Concern

  included do
    class_attribute :payment_deadline_column, instance_writer: false, default: :expires_at

    after_initialize :start_payment_window, if: :new_record?
    before_save :note_payment_deadline_change
    after_commit :schedule_payment_expiry

    # Scope bodies run against a relation, so the model's constants are reached through `klass`.
    scope :awaiting_payment, -> {
      where(status: klass::UNPAID).where("#{table_name}.#{payment_deadline_column} > NOW()")
    }
    scope :stale_unpaid, -> {
      where(status: klass::UNPAID).where("#{table_name}.#{payment_deadline_column} <= NOW()")
    }
    # Everything that still occupies capacity: paid, or unpaid and inside its window.
    scope :holding, -> {
      where(
        "#{table_name}.status = :paid OR (#{table_name}.status = :unpaid AND #{table_name}.#{payment_deadline_column} > NOW())",
        paid: klass::PAID, unpaid: klass::UNPAID
      )
    }
  end

  class_methods do
    def payment_window_length
      configatron.payment_window_minutes.to_i.minutes
    end

    def checkout_extension_length
      configatron.payment_checkout_minutes.to_i.minutes
    end

    def database_now
      connection.select_value("SELECT NOW()").to_time
    end
  end

  def payment_deadline
    self[payment_deadline_column]
  end

  # Seconds left by the database clock; 0 once the deadline has passed, or for an unsaved record.
  def time_remaining
    return 0 unless persisted? && payment_deadline.present?

    column = self.class.connection.quote_column_name(payment_deadline_column)
    self.class.connection.select_value(
      "SELECT GREATEST(0, EXTRACT(EPOCH FROM (#{column} - NOW()))::integer) FROM #{self.class.quoted_table_name} WHERE id = #{id.to_i}"
    ).to_i
  end

  def payment_window_open?
    is_unpaid? && time_remaining.positive?
  end
  alias_method :within_payment_window?, :payment_window_open?

  # True once the chance to pay on time has gone, whether or not the expiry job has run yet.
  def payment_window_expired?
    expired? || (is_unpaid? && !payment_window_open?)
  end

  # Where the order stands for the payment page: unpaid, paid, expired, cancelled or needs_reschedule.
  def payable_status
    return "paid" if status == self.class::PAID
    return "needs_reschedule" if respond_to?(:needs_reschedule?) && needs_reschedule?
    return "cancelled" if cancelled?
    return "unpaid" if payment_window_open?

    "expired"
  end

  # Safe to call early or twice: only an unpaid record whose deadline has passed by the database
  # clock is expired, so a job scheduled for a deadline that was later extended does nothing.
  def expire!
    expired_now = false
    with_lock do
      if is_unpaid? && time_remaining.zero?
        # A status-only change; skipping validation keeps old rows that no longer validate
        # (a retired class pack, say) from blocking the sweep.
        update_columns(status: self.class::EXPIRED, updated_at: Time.current)
        expired_now = true
      end
    end
    return false unless expired_now

    close_open_checkout!
    send_expiry_email if user.present? && respond_to?(:send_expiry_email, true)
    true
  end

  # Registering from the payment modal eats into the window, so a first registration restarts it.
  def reset_payment_window_once!
    move_deadline_once!(:payment_window_reset_at) do
      self.class.database_now + self.class.payment_window_length
    end
  end

  # The hold must never end before the invoice that pays for it. Starting checkout pushes the
  # deadline out to at least the checkout length, once, and the gateway invoice gets that deadline.
  def extend_for_checkout!
    move_deadline_once!(:checkout_extended_at) do
      [payment_deadline, self.class.database_now + self.class.checkout_extension_length].max
    end
  end

  private

  def start_payment_window
    return if payment_deadline.present?

    self[payment_deadline_column] = self.class.database_now + self.class.payment_window_length
  end

  def move_deadline_once!(stamp_column)
    moved = false
    with_lock do
      if payment_window_open? && self[stamp_column].nil?
        self[payment_deadline_column] = yield
        self[stamp_column] = Time.current
        save!(validate: false)
        moved = true
      end
    end
    moved
  end

  def close_open_checkout!
    Purchase.awaiting_payment.find_by(productable: self)&.expire_checkout!
  end

  # Remembered across every save in a transaction, so a record saved twice before commit (created,
  # then updated with its add-ons) still gets its job.
  def note_payment_deadline_change
    @payment_deadline_changed = true if new_record? || will_save_change_to_attribute?(payment_deadline_column)
  end

  def schedule_payment_expiry
    return unless @payment_deadline_changed

    @payment_deadline_changed = false
    return if destroyed? || !is_unpaid? || payment_deadline.blank?

    ExpirePaymentJob.set(wait_until: payment_deadline).perform_later(self)
  end
end
