class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.jsonb :name, default: {}
    end
  end
end
