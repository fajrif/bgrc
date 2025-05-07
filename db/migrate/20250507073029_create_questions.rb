class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.integer :order_no, null: false, default: 0
      t.jsonb :title, default: {}
      t.jsonb :description, default: {}
      t.string :section, null: false, default: ""
      t.timestamps
    end
  end
end
