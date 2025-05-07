class CreateSports < ActiveRecord::Migration[7.1]
  def change
    create_table :sports do |t|
      t.string :name, null: false, default: ""
      t.jsonb :short_description, default: {}
      t.jsonb :description, default: {}
      t.timestamps null: false
    end
    add_index :sports, :name, unique: true
  end
end
