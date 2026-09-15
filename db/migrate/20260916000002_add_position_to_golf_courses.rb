# Admins can run several golf courses (seasonal courses with their own rates) and order them; the
# first active course is the one customers book (GolfCourse.current).
class AddPositionToGolfCourses < ActiveRecord::Migration[7.1]
  def up
    add_column :golf_courses, :position, :integer, default: 0, null: false

    execute <<~SQL
      UPDATE golf_courses
      SET position = ranked.row_number
      FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number FROM golf_courses) ranked
      WHERE golf_courses.id = ranked.id
    SQL

    add_index :golf_courses, [:status, :position]
  end

  def down
    remove_index :golf_courses, [:status, :position]
    remove_column :golf_courses, :position
  end
end
