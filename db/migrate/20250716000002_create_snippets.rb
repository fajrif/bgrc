class CreateSnippets < ActiveRecord::Migration[7.1]
  def change
    create_table :snippets do |t|
      t.string :key, null: false
      t.string :title, null: false
      t.timestamps
    end

    add_index :snippets, :key, unique: true
  end
end
