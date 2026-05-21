class AddCreditValidityMonthsToGroupClasses < ActiveRecord::Migration[7.1]
  def change
    add_column :group_classes, :credit_validity_months, :integer
  end
end
