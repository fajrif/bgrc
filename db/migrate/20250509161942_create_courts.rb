class CreateCourts < ActiveRecord::Migration[7.1]
  def change
    create_table :courts do |t|
      t.string :name, null: false, default: ""
      t.belongs_to :sport
      t.integer :status, null: false, default: 0
      t.integer :min_duration, null: false, default: 1
      t.decimal :price, null: false, default: 0.0
      t.string :location, null: false, default: ""
      t.string :address, null: false, default: ""
      t.jsonb :info, default: {}
      t.jsonb :instructions, default: {}
      t.jsonb :description, default: {}
      t.timestamps
    end
    add_index :courts, :name, unique: true
  end
end
