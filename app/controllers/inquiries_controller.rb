class InquiriesController < ApplicationController

  def show
		@inquiry = Inquiry.new
    @banner = BannerSection.where(name: "Contact").first.banners.first
    @articles = Article.where(status: 1).first(3)
  end

  def create
		@success = false
		@inquiry = Inquiry.new(params_inquiry)

		if @inquiry.valid?
			unless @inquiry.use_v2.blank?
				unless Bgrc::Recaptcha.verify_recaptcha_v2?(params['g-recaptcha-response'], '_inquiry')
					flash[:alert] = t('global.recaptcha_failed')
					@show_recaptcha_v2 = true
				else
					create_data
				end
			else
				unless Bgrc::Recaptcha.verify_recaptcha?(params[:recaptcha_token], '_inquiry')
					flash[:alert] = t('global.recaptcha_failed')
					@show_recaptcha_v2 = true
				else
					create_data
				end
			end
		else
			flash[:alert] = t('inquiries.errors')
		end

    respond_to do |format|
      format.js
    end
  end

  private

  def params_inquiry
    params.require(:inquiry).permit(:name, :email, :phone, :message, :subject, :company_name, :use_v2)
  end

	def create_data
		if @inquiry.save
			flash[:notice] = t('inquiries.success')
			@success = true
			@inquiry = Inquiry.new
		else
			flash[:alert] = t('inquiries.errors')
		end
	end
end
