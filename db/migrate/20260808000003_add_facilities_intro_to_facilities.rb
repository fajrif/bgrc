class AddFacilitiesIntroToFacilities < ActiveRecord::Migration[7.1]
  def change
    add_column :facilities, :facilities_intro, :jsonb, default: {}
  end
end
