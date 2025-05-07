class AddRoleToAdmins < ActiveRecord::Migration[7.1]
  def change
		add_column :admins, :role_id, :integer, null: false, default: 0
  end
end
