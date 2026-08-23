class AddTimeWindowToGolfRates < ActiveRecord::Migration[7.1]
  def change
    add_column :golf_rates, :start_time, :string
    add_column :golf_rates, :end_time, :string
  end
end
