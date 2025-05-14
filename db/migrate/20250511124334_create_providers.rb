class CreateProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :providers do |t|
			t.belongs_to :user
			t.string :provider
			t.string :uid
			t.string :access_token
			t.string :access_secret
			t.timestamps
    end
  end
end
