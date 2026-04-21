class CreateRecurringEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :recurring_events do |t|
      t.string :title
      t.integer :court_id
      t.integer :day_of_week
      t.string :start_time
      t.string :end_time
    end
  end
end
