# A court booking is for 4 people and the court only unless a class or coach says otherwise. Those
# defaults used to be hardcoded in CourtBookingRequest; they now live on the columns.
class ChangeBookingPaxAndCourtTypeDefaults < ActiveRecord::Migration[7.1]
  def up
    change_column_default :bookings, :pax, from: 0, to: 4

    # Any booking saved without a type: a class or coach booking includes the coach (Booking::WITH_COACH),
    # anything else is court only (Booking::COURT_ONLY).
    execute <<~SQL
      UPDATE bookings
      SET court_type = CASE WHEN group_class_id IS NOT NULL OR coach_id IS NOT NULL THEN 1 ELSE 0 END
      WHERE court_type IS NULL
    SQL
    change_column_default :bookings, :court_type, from: nil, to: 0
    change_column_null :bookings, :court_type, false
  end

  def down
    change_column_null :bookings, :court_type, true
    change_column_default :bookings, :court_type, from: 0, to: nil
    change_column_default :bookings, :pax, from: 4, to: 0
  end
end
