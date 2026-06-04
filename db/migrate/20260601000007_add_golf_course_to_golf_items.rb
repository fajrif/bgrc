class AddGolfCourseToGolfItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :golf_items, :golf_course, null: true, foreign_key: true
  end
end
