class AddClassFieldsToGroupClasses < ActiveRecord::Migration[7.1]
  def change
    add_column :group_classes, :category, :string
    add_column :group_classes, :sport_id, :integer
    add_column :group_classes, :is_prescheduled, :boolean, default: false
    add_column :group_classes, :min_pack_sessions, :integer, default: 1
    add_column :group_classes, :max_pack_sessions, :integer, default: 1
  end
end
