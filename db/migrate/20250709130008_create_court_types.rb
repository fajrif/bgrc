class CreateCourtTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :court_types do |t|
      t.string :name, null: false, default: ""
    end
  end
end
