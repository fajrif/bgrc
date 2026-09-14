require "rqrcode"

class GolfReservation < ApplicationRecord
  default_scope { order(tee_time: :desc) }

  UNPAID    = 0
  PAID      = 1
  EXPIRED   = 2
  CANCELLED = 3
  # Paid after its hold lapsed and the tee time filled up meanwhile; see Booking::NEEDS_RESCHEDULE.
  NEEDS_RESCHEDULE = 4

  include PaymentWindow

  # Set when a paid reservation is moved or confirmed, so calculate_prices leaves the paid amount alone.
  attr_accessor :keep_paid_price

  scope :holding_or_rescheduling, -> { holding.or(where(status: NEEDS_RESCHEDULE)) }

  belongs_to :user, optional: true
  belongs_to :golf_course
  has_one :purchase, as: :productable
  has_many :golf_add_ons, dependent: :destroy

  validates_presence_of :tee_time, :order_id, :players_count, :holes
  validates_uniqueness_of :order_id
  validates :players_count, numericality: { greater_than: 0, less_than_or_equal_to: 4 }

  after_initialize :init_record, if: :new_record?
  before_validation :calculate_prices

  def init_record
    self.order_id = "GOLF#{SecureRandom.base58(8)}#{Time.now.to_i}".upcase if self.order_id.blank?
  end

  def calculate_prices
    return if keep_paid_price

    rate = GolfRate.find_rate(self.golf_course, self.holes, self.tee_time)
    self.green_fee = rate * self.players_count unless self.green_fee_changed?
    total_add_ons = self.persisted? ? self.golf_add_ons.reload.sum(&:total_price) : 0
    self.total_price = self.green_fee + total_add_ons
  end

  def is_unpaid?
    self.status == UNPAID
  end

  def expired?
    self.status == EXPIRED
  end

  def paid?
    self.status == PAID
  end

  def cancelled?
    self.status == CANCELLED
  end

  def needs_reschedule?
    self.status == NEEDS_RESCHEDULE
  end

  def guest?
    user_id.nil?
  end

  def gateway_paid?
    paid? && purchase.present? && purchase.payment_type != "CASHIER"
  end

  def cancel!
    self.status = CANCELLED
    self.save!
  end

  def paid!
    self.status = PAID
    self.save!
  end

  def create_purchase_record!(user: self.user)
    Purchase.create!(
      user: user,
      productable: self,
      token: "CASHIER-#{SecureRandom.base58(8)}",
      status_code: "200",
      status_message: "Cashier Payment",
      transaction_id: "CASHIER-#{Time.now.to_i}",
      gross_amount: self.total_price,
      payment_type: "CASHIER",
      transaction_status: "settlement",
      # Counter payment: no gateway was involved, so reconciliation must skip it.
      payment_gateway: PaymentGateways::CASHIER,
      paid_at: Time.current
    )
  end

  def name
    self.golf_course&.name
  end

  def order_name_label
    "#{self.try(:user).try(:name)} - #{self.order_id}"
  end

  def status_label
    return "Refunded" if refunded?
    case self.status
    when PAID      then "Paid"
    when EXPIRED   then "Expired"
    when CANCELLED then "Cancelled"
    when NEEDS_RESCHEDULE then "Needs reschedule"
    else "Unpaid"
    end
  end

  def green_fee_label
    ActionController::Base.helpers.number_to_currency(self.green_fee, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

  def total_price_label
    ActionController::Base.helpers.number_to_currency(self.total_price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

  def tee_time_label
    self.tee_time&.strftime("%A, %d %b %Y — %I:%M %p")
  end

  def holes_label
    "#{self.holes} Holes"
  end

  def send_email_notification!
    begin
      GolfReservationMailer.with(golf_reservation: self).confirmation_email.deliver_now
    rescue => e
      puts e.message
    end
    begin
      GolfReservationMailer.with(golf_reservation: self).new_reservation_email.deliver_now
    rescue => e
      puts e.message
    end
  end

  def qrcode
    qrcode = RQRCode::QRCode.new(self.order_id)
    qrcode.as_svg(color: "000", shape_rendering: "crispEdges", module_size: 8, standalone: true, use_path: true)
  end

  def self.players_booked_for(golf_course, tee_time_datetime, excluding: nil)
    scope = golf_course.golf_reservations
                       .holding
                       .where(tee_time: tee_time_datetime)
    scope = scope.where.not(id: excluding.id) if excluding&.persisted?
    scope.sum(:players_count)
  end

  def self.remaining_capacity_for(golf_course, tee_time_datetime, excluding: nil)
    [golf_course.max_players - players_booked_for(golf_course, tee_time_datetime, excluding: excluding), 0].max
  end

  def self.check_available?(golf_course, tee_time_datetime, players_count = 1, excluding: nil)
    remaining_capacity_for(golf_course, tee_time_datetime, excluding: excluding) >= players_count
  end

  # For a payment that landed after the hold lapsed: is there still room at this tee time?
  def slot_still_available?
    self.class.check_available?(golf_course, tee_time, players_count, excluding: self)
  end

  private

  def send_expiry_email
    begin
      GolfReservationMailer.with(golf_reservation: self).expired_email.deliver_now
    rescue => e
      puts e.message
    end
  end
end
