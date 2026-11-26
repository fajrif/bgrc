# Meeting review (23 Nov): tee times are every 15 minutes, and the course is in
# Nusa Dua, not Tuban. Only the default and the copy change; the admin can still
# set another interval, and GOLF_TEE_INTERVAL_MINUTES overrides it when present.
class MeetingReviewGolfAndLocation < ActiveRecord::Migration[7.1]
  def up
    change_column_default :golf_courses, :interval_minutes, from: 10, to: 15
    execute "UPDATE golf_courses SET interval_minutes = 15 WHERE interval_minutes = 10"
    execute "UPDATE golf_courses SET location = REPLACE(location, 'Tuban', 'Nusa Dua') WHERE location LIKE '%Tuban%'"
    execute "UPDATE facilities SET description = REPLACE(description::text, 'Tuban', 'Nusa Dua')::jsonb WHERE description::text LIKE '%Tuban%'"
    execute "UPDATE facilities SET short_description = REPLACE(short_description::text, 'Tuban', 'Nusa Dua')::jsonb WHERE short_description::text LIKE '%Tuban%'"
    execute "UPDATE testimonials SET comment = REPLACE(comment, 'Tuban', 'Nusa Dua') WHERE comment LIKE '%Tuban%'"
  end

  def down
    change_column_default :golf_courses, :interval_minutes, from: 15, to: 10
  end
end
