class CreateRecurringEventCourts < ActiveRecord::Migration[7.1]
  def up
    create_table :recurring_event_courts do |t|
      t.references :recurring_event, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true
      t.timestamps
    end
    add_index :recurring_event_courts, [:recurring_event_id, :court_id], unique: true, name: 'index_rec_event_courts_unique'

    # Data migration: copy existing court_id into the join table
    execute <<~SQL
      INSERT INTO recurring_event_courts (recurring_event_id, court_id, created_at, updated_at)
      SELECT id, court_id, NOW(), NOW()
      FROM recurring_events
      WHERE court_id IS NOT NULL
    SQL
  end

  def down
    drop_table :recurring_event_courts
  end
end
