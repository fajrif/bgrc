require "rqrcode"

class GolfReservation < ApplicationRecord
  default_scope { order(tee_time: :desc) }

  UNPAID    = 0
  PAID      = 1
  EXPIRED   = 2
  CANCELLED = 3

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
    if self.expires_at.nil?
      db_now = self.class.connection.select_value("SELECT NOW()")
      self.expires_at = db_now.to_time + 10.minutes
    end
  end

  def calculate_prices
    rate = GolfRate.find_rate(self.golf_course, self.holes, self.tee_time)
    self.green_fee = rate * self.players_count unless self.green_fee_changed?
    total_add_ons = self.persisted? ? self.golf_add_ons.reload.sum(&:total_price) : 0
    self.total_price = self.green_fee + total_add_ons
  end

  def is_unpaid?
    self.status == UNPAID
  end

  def payment_window_expired?
    expired?
  end

  def within_payment_window?
    is_unpaid?
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

  def guest?
    user_id.nil?
  end

  def midtrans_paid?
    paid? && purchase.present? && purchase.payment_type != "CASHIER"
  end

  def time_remaining
    return 0 unless expires_at.present? && persisted?
    result = self.class.connection.select_value(
      "SELECT GREATEST(0, EXTRACT(EPOCH FROM (expires_at - NOW()))::integer) FROM golf_reservations WHERE id = #{id}"
    )
    result.to_i
  end

  def expire!
    self.status = EXPIRED
    self.save!
    send_expiry_email if self.user.present?
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
      transaction_status: "settlement"
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
                       .where(status: [UNPAID, PAID])
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

  def self.expire_stale_reservations!
    GolfReservation.unscoped.where(status: UNPAID).where("expires_at < NOW()").find_each(&:expire!)
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
