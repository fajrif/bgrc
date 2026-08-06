class AddSportAndProfileToCoaches < ActiveRecord::Migration[7.1]
  def change
    # A coach now belongs to the sport they teach, so each sport page lists its
    # own team and the booking add-on can offer only relevant coaches.
    add_column :coaches, :sport_id, :integer
    add_index  :coaches, :sport_id

    # Translated profile copy, matching the TeamMember pattern.
    add_column :coaches, :role, :jsonb, default: {}
    add_column :coaches, :bio,  :jsonb, default: {}
  end
end
