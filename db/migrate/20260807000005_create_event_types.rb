class CreateEventTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :event_types do |t|
      t.jsonb   :name, default: {}
      t.jsonb   :short_description, default: {}
      t.integer :position, default: 0, null: false

      t.timestamps
    end
  end
end
