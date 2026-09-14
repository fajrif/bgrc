class Users::LateReschedulesController < Users::BaseController
  # Where a customer whose payment arrived after their slot was taken chooses a new time. Linked from the
  # late-payment email, My Bookings and the order's own page; the picker is a Vue component per kind
  # (LateRescheduleHelper#late_reschedule_app).
  def show
    @record = LateReschedule.pending_record(current_user, params[:type], params[:id])
    redirect_to users_bookings_path, notice: "This booking doesn't need a new time." if @record.nil?
  end
end
