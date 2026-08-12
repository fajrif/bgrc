class AddOrderingFieldsToMenus < ActiveRecord::Migration[7.1]
  def change
    add_column :menus, :menu_category_id, :integer
    add_column :menus, :price,            :decimal, precision: 15, scale: 2, default: 0, null: false
    add_column :menus, :discount_price,   :decimal, precision: 15, scale: 2
    add_column :menus, :in_stock,         :boolean, default: true, null: false
    # nil means the counter never runs out; a number decrements as orders are paid.
    add_column :menus, :stock_count,      :integer
    # Opt-in, so a menu card created for a restaurant page is never put on sale
    # before someone has given it a price and a category.
    add_column :menus, :orderable,        :boolean, default: false, null: false

    add_index :menus, :menu_category_id
    add_index :menus, :orderable
  end
end
