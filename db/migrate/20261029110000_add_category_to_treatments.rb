class AddCategoryToTreatments < ActiveRecord::Migration[7.1]
  def change
    add_column :treatments, :category, :string
  end
end
