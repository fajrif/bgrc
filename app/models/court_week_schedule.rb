# The business hours + a week of events (bookings, blocked slots, recurring events, class
# schedules) FullCalendar needs for one court's week grid. Built once for SearchController's
# first page render, and reused by Api::CourtsController#schedule so the Vue booking calendar
# can refetch it without a full page reload when the visitor changes court, type or week.
class CourtWeekSchedule
  attr_reader :business_hours, :events

  def initialize(court, from:)
    @court = court
    @view_start = from
    @view_end = from + 6.days
    build!
  end

  def min_open_time = @court.get_min_open_time
  def max_open_time = @court.get_max_open_time

  def as_json(*)
    { business_hours: business_hours, events: events, min_open_time: min_open_time, max_open_time: max_open_time }
  end

  private

  def build!
    @business_hours = @court.business_hours.map { |bh| { daysOfWeek: [bh.day_code], startTime: bh.open, endTime: bh.close } }

    bookings = @court.bookings.where("date >= ? AND status NOT IN (?, ?)", @view_start, Booking::EXPIRED, Booking::CANCELLED)
    @events = bookings.map { |b| { title: 'Booked', editable: false, className: 'booking-block', start: b.date.strftime('%Y-%m-%d %H:%M'), end: b.end_date.strftime('%Y-%m-%d %H:%M') } }

    recurring_events = @court.recurring_events.where(active: true)
    blocking_events = recurring_events.select { |re| re.hide? && re.one_time? }
    blocked_slots = []

    blocking_events.each do |re|
      (@view_start..@view_end).each do |day|
        next unless (re.specific_date..re.effective_end_date).cover?(day)
        blocked_slots << { date: day, start: re.start_time, end: re.end_time }
        @events << {
          title: '', editable: false, selectable: false,
          className: 'recurring-event-block',
          start: "#{day} #{re.start_time}",
          end:   "#{day} #{re.end_time}"
        }
      end
    end

    overlaps_block = ->(date, ev_start, ev_end) {
      blocked_slots.any? do |b|
        b[:date] == date &&
        Time.parse(b[:start]) < Time.parse(ev_end) &&
        Time.parse(b[:end]) > Time.parse(ev_start)
      end
    }

    recurring_events.each do |re|
      next if re.hide? && re.one_time?

      event_data = if re.hide?
        { title: '', editable: false, selectable: false, className: 'recurring-event-block' }
      else
        { title: re.title, editable: false, selectable: false, className: 'recurring-event-visible',
          extendedProps: { signUpUrl: Rails.application.routes.url_helpers.recurring_event_path(id: re.id) } }
      end

      if re.one_time?
        (@view_start..@view_end).each do |day|
          next unless (re.specific_date..re.effective_end_date).cover?(day)
          next if overlaps_block.call(day, re.start_time, re.end_time)
          @events << event_data.merge(start: "#{day} #{re.start_time}", end: "#{day} #{re.end_time}")
        end
      else
        (@view_start..@view_end).each do |day|
          next unless day.wday == re.day_of_week
          next if overlaps_block.call(day, re.start_time, re.end_time)
          @events << event_data.merge(start: "#{day} #{re.start_time}", end: "#{day} #{re.end_time}")
        end
      end
    end

    @court.group_class_schedules.includes(:group_class).each do |gcs|
      (@view_start..@view_end).each do |day|
        next unless day.wday == gcs.day_of_week
        next if overlaps_block.call(day, gcs.start_time, gcs.end_time)
        @events << {
          title: gcs.group_class.name,
          editable: false, selectable: false,
          className: 'class-schedule-block',
          start: "#{day} #{gcs.start_time}",
          end:   "#{day} #{gcs.end_time}",
          extendedProps: { classUrl: Rails.application.routes.url_helpers.group_class_path(id: gcs.group_class.id) }
        }
      end
    end
  end

end
