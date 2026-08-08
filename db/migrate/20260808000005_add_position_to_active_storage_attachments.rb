# Active Storage has no ordering of its own — attachments come back in insertion
# order — so gallery reordering needs a column to sort on.
class AddPositionToActiveStorageAttachments < ActiveRecord::Migration[7.1]
  def change
    add_column :active_storage_attachments, :position, :integer, default: 0, null: false
  end
end
