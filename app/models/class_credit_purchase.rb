class ClassCreditPurchase < ApplicationRecord
  PENDING   = 0
  PAID      = 1
  EXPIRED   = 2
  CANCELLED = 3
  # PaymentWindow's name for "created, not yet paid".
  UNPAID    = PENDING

  include PaymentWindow
  # expires_at already means how long a paid pack's credits stay valid.
  self.payment_deadline_column = :payment_expires_at

  belongs_to :user, optional: true
  belongs_to :group_class
  has_many :bookings, foreign_key: :class_credit_purchase_id
  has_many :group_class_registrations, dependent: :destroy
  has_one :purchase, as: :productable

  validates :sessions_count, numericality: { greater_than: 0 }
  validates :order_id, presence: true, uniqueness: true
  validate :sessions_count_within_pack_range

  after_initialize :init_record, if: :new_record?

  def paid?
    status == PAID
  end

  def is_unpaid?
    status == UNPAID
  end

  def expired?
    status == EXPIRED
  end

  def cancelled?
    status == CANCELLED
  end

  def sessions_used
    if group_class.is_prescheduled?
      group_class_registrations.active.count
    else
      bookings.where.not(status: [Booking::EXPIRED, Booking::CANCELLED]).count
    end
  end

  def sessions_remaining
    return 0 if group_class.is_prescheduled?
    return 0 if credit_expired?
    [sessions_count - sessions_used, 0].max
  end

  def credit_expired?
    expires_at.present? && expires_at < Time.current
  end

  def valid_credit?
    paid? && !credit_expired? && sessions_remaining > 0
  end

  def status_label
    case status
    when PAID      then "Paid"
    when EXPIRED   then "Expired"
    when CANCELLED then "Cancelled"
    else "Pending"
    end
  end

  def total_price
    price_paid
  end

  def price_label
    ActionController::Base.helpers.number_to_currency(price_paid, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

  def name
    "#{sessions_count} Session Credit – #{group_class.try(:name)}"
  end

  def mark_paid!
    attrs = { status: PAID }
    unless group_class.is_prescheduled?
      pack = group_class.group_class_packs.find_by(sessions_count: sessions_count)
      months = pack&.validity_months || group_class.credit_validity_months || configatron.credit_validity_months || 2
      attrs[:expires_at] = months.months.from_now
    end
    update!(attrs)
  end

  # `lapsed:` is true when the payment arrived after this purchase's hold on the place had gone.
  # The place is then only kept if the session still has room; otherwise the registration waits
  # for the customer to choose another session (BBCC does not refund).
  def book_initial_session!(lapsed: false)
    return unless initial_session_date && group_class
    return unless group_class.is_prescheduled?

    schedule = group_class.group_class_schedules.first
    return unless schedule

    seats = pax || group_class.min_pax
    status = if lapsed && group_class.slots_remaining_for(initial_session_date) < seats
      GroupClassRegistration::NEEDS_RESCHEDULE
    else
      GroupClassRegistration::REGISTERED
    end

    GroupClassRegistration.create!(
      user: user,
      group_class: group_class,
      class_credit_purchase: self,
      court: schedule.court,
      session_date: initial_session_date,
      pax: seats,
      status: status
    )
  end

  private

  def init_record
    self.order_id ||= "CCP#{SecureRandom.base58(8)}#{Time.now.to_i}".upcase
    self.purchase_date ||= Time.current
  end

  def sessions_count_within_pack_range
    return unless group_class
    packs = group_class.group_class_packs
    if packs.any?
      unless packs.exists?(sessions_count: sessions_count.to_i)
        errors.add(:sessions_count, "is not a valid pack option for this class")
      end
    else
      min = group_class.min_pack_sessions.to_i
      max = group_class.max_pack_sessions.to_i
      if sessions_count.to_i < min || sessions_count.to_i > max
        errors.add(:sessions_count, "must be between #{min} and #{max} for this class")
      end
    end
  end
end
