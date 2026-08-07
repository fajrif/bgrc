class AddExtraDescriptionsToRestaurants < ActiveRecord::Migration[7.1]
  def change
    add_column :restaurants, :banner_description, :jsonb, default: {}
    add_column :restaurants, :description1, :jsonb, default: {}
    add_column :restaurants, :description2, :jsonb, default: {}
  end
end
