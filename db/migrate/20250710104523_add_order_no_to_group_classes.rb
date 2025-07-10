class AddOrderNoToGroupClasses < ActiveRecord::Migration[7.1]
  def change
    add_column :group_classes, :order_no, :integer
  end
end
