class AddHideToRecurringEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_events, :hide, :boolean, default: false, null: false
  end
end
