class CreateTeamMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :team_members do |t|
      t.string :name, default: "", null: false
      t.string :department, default: "sports", null: false
      t.jsonb :role, default: {}
      t.jsonb :bio, default: {}
      t.integer :position, default: 0, null: false

      t.timestamps
    end
  end
end
