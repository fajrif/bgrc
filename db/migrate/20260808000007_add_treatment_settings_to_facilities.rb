class AddTreatmentSettingsToFacilities < ActiveRecord::Migration[7.1]
  def change
    # Heading over the treatment card row — "Treatment" on Spa and Recovery,
    # "Services" on Anti Aging.
    add_column :facilities, :treatments_title, :jsonb, default: {}
    add_column :facilities, :show_specialists, :boolean, default: true, null: false
  end
end
