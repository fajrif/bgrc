class UpdateRecurringEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_events, :specific_date, :date
    add_column :recurring_events, :description,   :text
    add_column :recurring_events, :capacity,      :integer, default: 0
    remove_column :recurring_events, :group_class_id, :integer
  end
end
