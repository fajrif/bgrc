require "rqrcode"

# A Grab & Go counter order. Mirrors GolfReservation: it is a Purchase productable,
# it holds an unpaid slot for ten minutes, and it carries its own line items.
class FoodOrder < ApplicationRecord
  default_scope { order(created_at: :desc) }

  UNPAID    = 0
  PAID      = 1
  EXPIRED   = 2
  CANCELLED = 3

  PENDING   = 0
  PREPARING = 1
  READY     = 2
  COLLECTED = 3

  FULFILLMENT_LABELS = {
    PENDING   => "Pending",
    PREPARING => "Preparing",
    READY     => "Ready for pickup",
    COLLECTED => "Collected"
  }.freeze

  PICKUP_LOCATION = "Grab & Go counter, near the main clubhouse area".freeze

  belongs_to :user, optional: true
  has_one :purchase, as: :productable
  has_many :food_order_items, dependent: :destroy

  validates_presence_of :order_id, :customer_name, :customer_phone
  validates_uniqueness_of :order_id
  validate :must_have_items

  after_initialize :init_record, if: :new_record?
  before_save :calculate_prices

  def init_record
    self.order_id = "GNG#{SecureRandom.base58(8)}#{Time.now.to_i}".upcase if self.order_id.blank?
    if self.expires_at.nil?
      # DB clock, so the countdown and the sweep can never disagree about "now".
      db_now = self.class.connection.select_value("SELECT NOW()")
      self.expires_at = db_now.to_time + 10.minutes
    end
  end

  def calculate_prices
    self.total_price = food_order_items.reject(&:marked_for_destruction?).sum(&:total_price)
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

  def gateway_paid?
    paid? && purchase.present? && purchase.payment_type != "CASHIER"
  end

  def time_remaining
    return 0 unless expires_at.present? && persisted?
    result = self.class.connection.select_value(
      "SELECT GREATEST(0, EXTRACT(EPOCH FROM (expires_at - NOW()))::integer) FROM food_orders WHERE id = #{id}"
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
    food_order_items.each { |item| item.menu&.decrement_stock!(item.quantity) }
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

  def cashier_order?
    purchase&.payment_type == "CASHIER"
  end

  # Purchase#init_record and the gateway adapters both read this.
  def name
    "Grab & Go Order #{order_id}"
  end

  def order_name_label
    "#{customer_name} - #{order_id}"
  end

  def items_count
    food_order_items.sum(:quantity)
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

  def fulfillment_label
    FULFILLMENT_LABELS[self.fulfillment_status] || FULFILLMENT_LABELS[PENDING]
  end

  def pickup_label
    pickup_at.present? ? pickup_at.strftime("%A, %d %b %Y — %I:%M %p") : "As soon as possible"
  end

  def total_price_label
    ActionController::Base.helpers.number_to_currency(self.total_price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end

  # A real per-dish breakdown on the gateway's checkout page and receipt, instead
  # of the single collapsed line PaymentGateways::Base falls back to.
  def gateway_item_details
    food_order_items.map do |item|
      {
        "id"       => item.menu_id.to_s,
        "price"    => item.price.to_i,
        "quantity" => item.quantity,
        "name"     => item.name.to_s.truncate(50),
        "category" => "Grab & Go"
      }
    end
  end

  def send_email_notification!
    begin
      FoodOrderMailer.with(food_order: self).confirmation_email.deliver_now
    rescue => e
      puts e.message
    end
    begin
      FoodOrderMailer.with(food_order: self).new_order_email.deliver_now
    rescue => e
      puts e.message
    end
  end

  def qrcode
    RQRCode::QRCode.new(self.order_id).as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 8,
      standalone: true,
      use_path: true
    )
  end

  def self.expire_stale_orders!
    FoodOrder.unscoped.where(status: UNPAID).where("expires_at < NOW()").find_each(&:expire!)
  end

  private

  def must_have_items
    errors.add(:base, "Your order is empty.") if food_order_items.reject(&:marked_for_destruction?).empty?
  end

  def send_expiry_email
    begin
      FoodOrderMailer.with(food_order: self).expired_email.deliver_now
    rescue => e
      puts e.message
    end
  end
end
