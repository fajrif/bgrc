class RemoveCourtIdFromRecurringEvents < ActiveRecord::Migration[7.1]
  def up
    remove_column :recurring_events, :court_id, :integer
  end

  def down
    add_column :recurring_events, :court_id, :integer
  end
end
