class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.jsonb :name, default: {}
      t.jsonb :short_description, default: {}
      t.jsonb :description, default: {}
      t.datetime :start_date, null: true
      t.datetime :end_date, null: true
			t.references :sport
    end
    add_index :events, :name, unique: true
  end
end
