class AddTimestampsToEventRsvps < ActiveRecord::Migration[7.1]
  def change
    add_timestamps :event_rsvps, default: Time.current, null: false
    change_column_default :event_rsvps, :created_at, from: Time.current, to: nil
    change_column_default :event_rsvps, :updated_at, from: Time.current, to: nil
  end
end
