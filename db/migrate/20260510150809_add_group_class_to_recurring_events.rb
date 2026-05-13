class AddGroupClassToRecurringEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_events, :group_class_id, :integer
  end
end
