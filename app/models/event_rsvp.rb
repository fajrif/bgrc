class EventRsvp < ApplicationRecord
  belongs_to :recurring_event

  GENDERS = ["Male", "Female", "Prefer not to say"].freeze

  validates :full_name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :event_has_capacity

  private

  def event_has_capacity
    return unless recurring_event
    cap = recurring_event.capacity
    if cap > 0 && recurring_event.event_rsvps.where.not(id: id).count >= cap
      errors.add(:base, "Sorry, this event is fully booked.")
    end
  end
end
