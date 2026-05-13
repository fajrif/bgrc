class AddCalendarColorToGroupClasses < ActiveRecord::Migration[7.1]
  def change
    add_column :group_classes, :calendar_color, :string, default: '#0d6efd'
  end
end
