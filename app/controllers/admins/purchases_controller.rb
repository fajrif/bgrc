class Admins::PurchasesController < Admins::BaseController

  def index
		criteria = Purchase.joins(:user).where("full_name ILIKE ?", "%#{params[:search]}%")
		case params[:status_code]
		when "Success"
			criteria = criteria.where(status_code: Purchase::SUCCESS_CODE)
		when "Pending"
			criteria = criteria.where(status_code: Purchase::PENDING_CODE)
		end
    @purchases = criteria.page(params[:page]).per(500)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @purchases }
      format.js
			format.xls { send_data helpers.generate_purchases_csv(@purchases), :filename => "Purchases-Data.xls" }
    end
  end

	def export_all
		@purchases = Purchase.all

    respond_to do |format|
			format.xls { send_data helpers.generate_purchases_csv(@purchases), :filename => "Purchases-All.xls" }
    end
	end

  def show
		@purchase = Purchase.find(params[:id])
  end

  def destroy
		@purchase = Purchase.find(params[:id])
    if @purchase.productable.is_a?(ClassCreditPurchase)
      @purchase.productable.destroy!
    end
    @purchase.destroy
    redirect_to admins_purchases_url, :notice => "Successfully destroyed purchase."
  end

  def settlement
		@purchase = Purchase.find(params[:id])
    if @purchase.make_settlement!
			redirect_to admins_purchase_path(@purchase), :notice => "Successfully make settlement."
		else
			redirect_to admins_purchase_path(@purchase), :alert => "Unable to make settlement."
		end
  end

end
