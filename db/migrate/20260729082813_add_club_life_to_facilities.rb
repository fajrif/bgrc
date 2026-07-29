class AddClubLifeToFacilities < ActiveRecord::Migration[7.1]
  def change
    add_column :facilities, :parent_id, :integer
    add_column :facilities, :sport_id, :integer
    add_column :facilities, :position, :integer, default: 0, null: false
    add_column :facilities, :club_life, :boolean, default: false, null: false
    add_column :facilities, :cta_label, :jsonb, default: {}
    add_column :facilities, :cta_url, :string, default: "", null: false

    add_index :facilities, :parent_id
    add_index :facilities, :sport_id
  end
end
