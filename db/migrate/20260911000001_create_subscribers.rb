class CreateSubscribers < ActiveRecord::Migration[7.1]
	def change
		create_table :subscribers do |t|
			t.string :email, null: false
			t.timestamps
		end
		add_index :subscribers, "lower(email)", unique: true, name: "index_subscribers_on_lower_email"
	end
end
