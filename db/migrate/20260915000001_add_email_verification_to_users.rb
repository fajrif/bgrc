class AddEmailVerificationToUsers < ActiveRecord::Migration[7.1]
  def change
    # A keyed digest of the six-digit code emailed to accounts created from the payment modal;
    # the code itself is never stored.
    add_column :users, :verification_code_digest, :string
    add_column :users, :verification_code_sent_at, :datetime
    add_column :users, :verification_attempts, :integer, default: 0, null: false

    # Set by the short payment-modal sign-up, cleared once date of birth and nationality are added.
    add_column :users, :profile_incomplete, :boolean, default: false, null: false
  end
end
