class ClassCreditPurchasesController < ApplicationController
  include PaymentReconciliation
  # Purchases are created by Api::ClassCreditPurchasesController from the group class page, and
  # sessions are claimed by Api::ClassSessionClaimsController from book_session. A guest may open a
  # purchase their session made; paying goes through Api::CheckoutsController, which requires an account.
  before_action :authenticate_user!, only: [:book_session]
  before_action :set_credit_purchase, only: [:show, :book_session]

  def show
    # Purchases are addressed by a sequential id, so a guest only reaches one their own session made.
    if user_signed_in? && @credit_purchase.user_id.nil? && session_owns?(@credit_purchase)
      @credit_purchase.update_columns(user_id: current_user.id, updated_at: Time.current)
      forget_guest_order!(@credit_purchase)
    end
    owner = user_signed_in? && @credit_purchase.user_id == current_user.id
    guest = @credit_purchase.user_id.nil? && session_owns?(@credit_purchase)
    return redirect_to(root_path, alert: "Access denied.") unless owner || guest

    store_location_for(:user, request.fullpath)
    @reschedulable_bookings = @credit_purchase.bookings
                                .where(status: Booking::PAID)
                                .where("created_at > ?", 24.hours.ago)
    @registration = @credit_purchase.group_class_registrations.active.first if @credit_purchase.group_class.is_prescheduled?

    # A gateway redirect can beat its own webhook back here.
    settle_pending_payment!(@credit_purchase)
  end

  # The calendar itself is ClassSessionClaimApp (app/frontend/components/classes).
  def book_session
    return redirect_to root_path, alert: "Access denied." unless @credit_purchase.user == current_user
    unless @credit_purchase.valid_credit?
      redirect_to class_credit_purchase_path(@credit_purchase),
                  alert: "No sessions remaining or credit is invalid." and return
    end
    if @credit_purchase.group_class.is_prescheduled?
      redirect_to group_class_path(@credit_purchase.group_class),
                  alert: "Prescheduled classes are booked from the class page." and return
    end

    @group_class = @credit_purchase.group_class
  end

  private

  def set_credit_purchase
    @credit_purchase = ClassCreditPurchase.find(params[:id])
  end
end
