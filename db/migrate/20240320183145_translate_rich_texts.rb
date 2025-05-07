class TranslateRichTexts < ActiveRecord::Migration[7.1]
  def change
		add_column :action_text_rich_texts, :locale, :string, null: true

    remove_index :action_text_rich_texts,
                 column: [:record_type, :record_id, :name],
                 name: :index_action_text_rich_texts_uniqueness,
                 unique: true
    add_index :action_text_rich_texts,
              [:record_type, :record_id, :name, :locale],
              name: :index_action_text_rich_texts_uniqueness,
              unique: true
  end
end
