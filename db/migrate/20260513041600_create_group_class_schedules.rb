class CreateGroupClassSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :group_class_schedules do |t|
      t.references :group_class, null: false, foreign_key: true
      t.references :court,       null: false, foreign_key: true
      t.integer    :day_of_week, null: false
      t.string     :start_time,  null: false
      t.string     :end_time,    null: false
      t.timestamps
    end
  end
end
