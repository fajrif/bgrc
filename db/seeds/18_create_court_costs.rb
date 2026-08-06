# Day / Evening pricing windows for every court.
#
# Idempotent: upserts on (court, day_code, start_time) and never deletes, so it is
# safe to re-run on production — a window an admin has repriced keeps its price
# unless this seed's own value changed.
#
# Two constraints come from Court#calculate_price:
#   * matching Cost rows are SUMMED, not resolved, so the windows must not overlap;
#   * the end hour is inclusive (`dc.hour <= end_time.hour`), which is why the day
#     window ends at 16:00 and the evening window starts at 17:00.
puts "ensure court pricing windows"

WINDOWS = [
  { start_time: "06:00", end_time: "16:00", multiplier: 1.0 },   # day
  { start_time: "17:00", end_time: "22:00", multiplier: 1.5 },   # evening
].freeze

created = 0

Court.find_each do |court|
  next if court.price.to_f.zero?

  7.times do |day_code|
    WINDOWS.each do |window|
      cost = Cost.find_or_initialize_by(court_id: court.id, day_code: day_code, start_time: window[:start_time])
      next if cost.persisted?

      cost.end_time = window[:end_time]
      cost.price    = (court.price * window[:multiplier]).round
      cost.save!
      created += 1
    end
  end
end

puts "Court pricing windows: #{created} created, #{Cost.count} total"
