class GroupClassRegistration < ApplicationRecord
  REGISTERED = 0
  CANCELLED = 1

  belongs_to :user
  belongs_to :group_class
  belongs_to :class_credit_purchase, optional: true
  belongs_to :court

  validates :session_date, :pax, presence: true
  validates :pax, numericality: { greater_than: 0 }

  scope :active, -> { where(status: REGISTERED) }

  def status_label
    status == REGISTERED ? "Registered" : "Cancelled"
  end
end
