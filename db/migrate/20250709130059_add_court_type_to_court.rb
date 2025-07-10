class AddCourtTypeToCourt < ActiveRecord::Migration[7.1]
  def change
    add_column :courts, :court_type_id, :integer
  end
end
