class BackfillUserConfirmedAt < ActiveRecord::Migration[7.1]
  # Devise :confirmable is being enabled on User. Every existing row has
  # confirmed_at NULL, and allow_unconfirmed_access_for is unset (defaults to
  # 0.days), so without this backfill every current user would be blocked from
  # signing in the moment confirmable goes live.
  #
  # Raw SQL on purpose: the User model change ships in the same deploy, so this
  # must not depend on how the model is currently configured.
  def up
    execute "UPDATE users SET confirmed_at = NOW() WHERE confirmed_at IS NULL"
  end

  def down
    # Irreversible by design: we cannot tell which users were confirmed here
    # versus genuinely confirmed by clicking through an email.
  end
end
