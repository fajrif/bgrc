class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
			t.string :name, null: false, default: ""
			t.string :description, null: false, default: ""
    end
  end
end
