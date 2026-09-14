# Anyone can create a booking, tee time, food order or class credit purchase before signing in;
# paying needs an account. The session remembers what a guest created, so the guest can reach it
# again and it moves into their account the moment they sign in, register or verify.
module GuestOrders
  extend ActiveSupport::Concern

  SESSION_KEYS = {
    "Booking"             => :guest_booking_order_ids,
    "GolfReservation"     => :guest_golf_order_ids,
    "FoodOrder"           => :guest_food_order_ids,
    "ClassCreditPurchase" => :guest_credit_purchase_ids,
  }.freeze

  private

  def track_guest_order!(record)
    key = SESSION_KEYS.fetch(record.class.name)
    session[key] = Array(session[key]) | [record.order_id]
  end

  def forget_guest_order!(record)
    key = SESSION_KEYS.fetch(record.class.name)
    session[key] = Array(session[key]) - [record.order_id]
  end

  def session_owns?(record)
    return false if record.nil?

    Array(session[SESSION_KEYS.fetch(record.class.name)]).include?(record.order_id)
  end

  # Moves every still-unclaimed order this session created into `user`'s account. update_columns
  # on purpose: claiming an order must not reprice it or reset its payment window.
  def adopt_guest_orders!(user)
    SESSION_KEYS.each do |class_name, key|
      order_ids = Array(session[key])
      next if order_ids.empty?

      class_name.constantize.unscoped.where(order_id: order_ids, user_id: nil).find_each do |record|
        record.update_columns(user_id: user.id, updated_at: Time.current)
      end
      session.delete(key)
    end
  end
end
