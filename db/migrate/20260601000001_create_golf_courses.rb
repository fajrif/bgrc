class CreateGolfCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :golf_courses do |t|
      t.string :name, null: false
      t.jsonb :description, default: {}
      t.string :holes_available, default: "9,18"
      t.integer :interval_minutes, default: 10
      t.integer :max_players, default: 4
      t.string :location
      t.string :slug
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :golf_courses, :slug, unique: true
  end
end
