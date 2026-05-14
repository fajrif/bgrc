class CreateGroupClassRegistrations < ActiveRecord::Migration[7.1]
  def change
    create_table :group_class_registrations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group_class, null: false, foreign_key: true
      t.references :class_credit_purchase, null: true, foreign_key: true
      t.references :court, null: false, foreign_key: true
      t.datetime :session_date, null: false
      t.integer :pax, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
