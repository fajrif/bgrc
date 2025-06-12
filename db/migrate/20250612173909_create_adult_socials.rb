class CreateAdultSocials < ActiveRecord::Migration[7.1]
  def change
    create_table :adult_socials do |t|
      t.belongs_to :sport
      t.jsonb :title, default: {}
      t.jsonb :short_description, default: {}
      t.jsonb :description, default: {}
      t.datetime :start_date, null: true
      t.integer :duration, null: false, default: 0
      t.integer :gender, null: false, default: 0
      t.integer :invitation_only, null: false, default: 0
      t.integer :size, null: false, default: 0
			t.decimal :price, null: false, default: 0.0
    end
  end
end
