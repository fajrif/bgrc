class AddActiveToRecurringEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_events, :active, :boolean, default: true, null: false
  end
end
