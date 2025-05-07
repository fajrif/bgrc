class CreateTestimonials < ActiveRecord::Migration[7.1]
  def change
    create_table :testimonials do |t|
			t.string :name, null: false, default: ""
			t.string :email, null: false, default: ""
			t.string :company_name, null: false, default: ""
			t.string :comment, null: false, default: ""
      t.timestamps null: false
    end
  end
end
