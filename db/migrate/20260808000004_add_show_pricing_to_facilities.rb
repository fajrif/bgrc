class AddShowPricingToFacilities < ActiveRecord::Migration[7.1]
  def change
    add_column :facilities, :show_pricing, :boolean, default: true, null: false
  end
end
