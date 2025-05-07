class Admins::InquiriesController < Admins::BaseController

  def index
    criteria = Inquiry.where("name ILIKE ? OR email ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    @inquiries = criteria.page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inquiries }
      format.js
    end
  end

  def show
    @inquiry = Inquiry.find(params[:id])
  end

  def destroy
    @inquiry = Inquiry.find(params[:id])
    @inquiry.destroy
    redirect_to admins_inquiries_url, :notice => "Successfully delete inquiry."
  end

end
