class AddShortDescriptionToRecurringEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_events, :short_description, :text
  end
end
