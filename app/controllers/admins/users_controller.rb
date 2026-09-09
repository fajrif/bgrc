class Admins::UsersController < Admins::BaseController

  def index
    criteria = User.where("full_name LIKE ?", "%#{params[:search]}%")
    @users = criteria.page(params[:page]).per(50)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.js
			format.xls { send_data helpers.generate_users_csv(@users), :filename => "Users-Data.xls" }
    end
  end

	def export_all
		@users = User.all

    respond_to do |format|
			format.xls { send_data helpers.generate_users_csv(@users), :filename => "Users-All.xls" }
    end
	end

	# Feeds the user picker modal on the cashier booking forms. ILIKE (not the
	# case-sensitive LIKE used by #index) so an admin can type any casing, and
	# reorder because User carries a default_scope ordering by created_at.
	def search
		term = params[:term].to_s.strip
		@users = if term.blank?
			User.reorder(full_name: :asc).limit(20)
		else
			User.where("full_name ILIKE :q OR email ILIKE :q", :q => "%#{term}%")
					.reorder(full_name: :asc).limit(20)
		end

		respond_to do |format|
			format.js
		end
	end

	# Creates a walk-in customer from the picker modal. The password is a throwaway
	# random token nobody ever sees - the user sets their own via the Devise
	# confirmation email that :confirmable fires on create.
	def create
		@user = User.new(params_user_create)
		@user.admin_created = true
		@user.password = Devise.friendly_token[0, 20]
		@user.save

		respond_to do |format|
			format.js
		end
	end

  def show
		@user = User.find(params[:id])
		@credit_purchases = @user.class_credit_purchases.includes(:group_class).order(created_at: :desc)
    @bookings = @user.bookings.includes(:court, :group_class, :purchase).order(created_at: :desc).limit(50)
    @purchases = @user.purchases.order(created_at: :desc).limit(50)
  end

  def edit
		@user = User.find(params[:id])
  end

	def update
		@user = User.find(params[:id])
		# config.reconfirmable is on, so without this an admin editing a user's
		# email would only stage it in unconfirmed_email rather than applying it.
		@user.skip_reconfirmation!
		if @user.update(params_user)
			redirect_to admins_user_path(@user), :notice  => "Successfully updated user."
		else
			render :action => 'edit'
		end
	end

  def destroy
		@user = User.find(params[:id])
    @user.destroy
    redirect_to admins_users_url, :notice => "Successfully destroyed user."
  end

	# Re-sends the Devise confirmation ("verify your email") link.
	def send_confirmation
		@user = User.find(params[:id])

		if @user.confirmed?
			redirect_back fallback_location: admins_users_path, :alert => "#{@user.email} is already verified."
		else
			@user.send_confirmation_instructions
			redirect_back fallback_location: admins_users_path, :notice => "Verification email sent to #{@user.email}."
		end
	end

	# Sends the Devise "forgot password" link so the user can set their own password.
	def send_reset_password
		@user = User.find(params[:id])
		@user.send_reset_password_instructions
		redirect_back fallback_location: admins_users_path, :notice => "Reset password email sent to #{@user.email}."
	end

  private

  def params_user
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name, :gender, :phone, :nationality, :dob)
  end

	# Deliberately narrow: the cashier modal only collects what a walk-in customer
	# can supply at the counter. Password is set server-side, never from params.
	def params_user_create
		params.require(:user).permit(:full_name, :email, :phone)
	end

end
