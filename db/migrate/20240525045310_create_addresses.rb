class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.integer :order_no, null: false, default: 0
      t.jsonb :name, default: {}
      t.string :complete_address, null: false, default: ""
      t.string :phone1, null: false, default: ""
      t.string :phone2, null: false, default: ""
      t.string :fax, null: false, default: ""
      t.string :email1, null: false, default: ""
      t.string :email2, null: false, default: ""
      t.string :longitude, null: false, default: ""
      t.string :latitude, null: false, default: ""
      t.timestamps
    end
  end
end
