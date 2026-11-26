# Sign-up no longer asks for gender. Leaving the column at its old default would
# record every new account as Female, so it starts empty and stays optional.
class MakeUserGenderOptional < ActiveRecord::Migration[7.1]
  def up
    change_column_null :users, :gender, true
    change_column_default :users, :gender, from: 0, to: nil
  end

  def down
    execute "UPDATE users SET gender = 0 WHERE gender IS NULL"
    change_column_default :users, :gender, from: nil, to: 0
    change_column_null :users, :gender, false
  end
end
