class AddIntroFieldsToRestaurants < ActiveRecord::Migration[7.1]
  def change
    # The three labelled lines under the intro copy (Concept / Operating Hours /
    # Location). Optional for every venue — the block is skipped when they're blank.
    add_column :restaurants, :concept,         :jsonb, default: {}
    add_column :restaurants, :operating_hours, :jsonb, default: {}
    add_column :restaurants, :location_note,   :jsonb, default: {}
  end
end
