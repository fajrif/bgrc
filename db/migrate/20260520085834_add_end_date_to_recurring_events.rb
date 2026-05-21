class AddEndDateToRecurringEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :recurring_events, :end_date, :date
  end
end
