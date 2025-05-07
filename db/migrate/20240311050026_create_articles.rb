class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.jsonb :title, default: {}
      t.jsonb :short_description, default: {}
			t.references :category
			t.datetime :published_date
      t.integer :status, null: false, default: 1
			t.string :video_url, null: false, default: ""
			t.string :tags, null: false, default: ""
      t.timestamps null: false
    end
    add_index :articles, :title, unique: true
  end
end
