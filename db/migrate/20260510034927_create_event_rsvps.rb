class CreateEventRsvps < ActiveRecord::Migration[7.1]
  def change
    create_table :event_rsvps do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
    end
  end
end
