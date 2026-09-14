class GroupClassRegistration < ApplicationRecord
  REGISTERED = 0
  CANCELLED = 1
  # The credit was paid after its hold lapsed and the session filled up meanwhile; the customer
  # chooses another session at the price already paid.
  NEEDS_RESCHEDULE = 2

  belongs_to :user
  belongs_to :group_class
  belongs_to :class_credit_purchase, optional: true
  belongs_to :court

  validates :session_date, :pax, presence: true
  validates :pax, numericality: { greater_than: 0 }

  scope :active, -> { where(status: REGISTERED) }

  def needs_reschedule?
    status == NEEDS_RESCHEDULE
  end

  def status_label
    case status
    when REGISTERED       then "Registered"
    when NEEDS_RESCHEDULE then "Needs reschedule"
    else "Cancelled"
    end
  end
end
