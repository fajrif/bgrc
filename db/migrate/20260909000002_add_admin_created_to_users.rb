class AddAdminCreatedToUsers < ActiveRecord::Migration[7.1]
  # Marks accounts created by staff from the admin panel (the cashier user
  # picker), which are allowed to exist without dob/nationality.
  #
  # This has to be a real column rather than a transient attr_accessor: the
  # relaxed validation must hold for every later save of that record too - a
  # password reset, for instance, calls save and would otherwise be rejected
  # for the still-blank profile fields.
  def change
    add_column :users, :admin_created, :boolean, default: false, null: false
  end
end
