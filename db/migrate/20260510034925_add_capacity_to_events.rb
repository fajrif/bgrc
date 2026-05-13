class AddCapacityToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :capacity, :integer, default: 0
  end
end
