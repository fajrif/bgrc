class UpdateEventRsvps < ActiveRecord::Migration[7.1]
  def change
    rename_column :event_rsvps, :name,     :full_name
    rename_column :event_rsvps, :event_id, :recurring_event_id
    add_column    :event_rsvps, :dob,      :date
    add_column    :event_rsvps, :gender,   :string
    add_column    :event_rsvps, :address,  :text
  end
end
