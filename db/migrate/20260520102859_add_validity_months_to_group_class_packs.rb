class AddValidityMonthsToGroupClassPacks < ActiveRecord::Migration[7.1]
  def change
    add_column :group_class_packs, :validity_months, :integer
  end
end
