class ClassCreditPurchasesController < ApplicationController
  before_action :authenticate_user!, only: [:show, :initiate_payment, :payment_callback]
  before_action :set_credit_purchase, only: [:show, :initiate_payment, :payment_callback]

  def create
    @group_class = GroupClass.find(params.dig(:class_credit_purchase, :group_class_id))
    sessions_count = params.dig(:class_credit_purchase, :sessions_count).to_i
    @initial_session_date = params.dig(:class_credit_purchase, :initial_session_date)

    submitted_pax = params.dig(:class_credit_purchase, :pax).to_i
    submitted_pax = @group_class.min_pax if submitted_pax < @group_class.min_pax

    pack = @group_class.group_class_packs.find_by(sessions_count: sessions_count)
    total_price = pack ? pack.price : (@group_class.check_price(submitted_pax, false) * sessions_count)

    parsed_initial_date = DateTime.strptime(@initial_session_date, "%d/%m/%Y %H:%M") rescue nil

    @credit_purchase = ClassCreditPurchase.new(
      user: current_user,
      group_class: @group_class,
      sessions_count: sessions_count,
      price_paid: total_price,
      purchase_date: Time.current,
      status: ClassCreditPurchase::PENDING,
      initial_session_date: parsed_initial_date
    )

    if @credit_purchase.save
      session[:credit_purchase_initial_date] = @initial_session_date
      if user_signed_in?
        redirect_to class_credit_purchase_path(@credit_purchase), notice: "Credit purchase created. Please complete your payment."
      else
        store_location_for(:user, class_credit_purchase_path(@credit_purchase))
        redirect_to new_user_session_path, alert: "Please sign in to complete your purchase."
      end
    else
      redirect_to search_path, alert: @credit_purchase.errors.full_messages.to_sentence
    end
  end

  def show
    unless @credit_purchase.user == current_user
      redirect_to root_path, alert: "Access denied."
    end
  end

  def initiate_payment
    begin
      existing = Purchase.find_by(productable: @credit_purchase, user: current_user, status_code: "000")
      existing.destroy if existing
      @purchase = Purchase.new(productable: @credit_purchase, user: current_user, status_code: "000")
      @purchase.save!
      respond_to { |f| f.js }
    rescue => e
      flash.now[:alert] = e.message
      respond_to { |f| f.js { render "initiate_payment_error" } }
    end
  end

  def payment_callback
    @purchase = Purchase.find_or_initialize_by(
      order_id: params[:order_id],
      token: params[:token],
      productable: @credit_purchase,
      user: current_user
    )
    unless @purchase.status_code.in?(["200", "201"])
      if @purchase.save_with_result(params)
        @purchase.process_after_success! if @purchase.status_code == "200"
        flash[:notice] = "Payment successful. Your session credits are now active."
      else
        flash[:alert] = "Payment processing error. Please contact support."
      end
    end
    respond_to { |f| f.js }
  end

  private

  def set_credit_purchase
    @credit_purchase = ClassCreditPurchase.find(params[:id])
  end
end
