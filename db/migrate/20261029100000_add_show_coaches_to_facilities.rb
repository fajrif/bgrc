class AddShowCoachesToFacilities < ActiveRecord::Migration[7.1]
  def change
    add_column :facilities, :show_coaches, :boolean, default: false, null: false
  end
end
