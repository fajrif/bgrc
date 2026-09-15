// The club's clock in the browser. Booking times are club wall-clock times (CLUB_TIME_ZONE), but the
// visitor's device can be anywhere. The layout's `club-now` meta tag carries the club's wall-clock time
// when the page was served; keeping its offset from the device clock makes "now" match the club.

let offset: number | null = null

function readOffset(): number {
  const content = document.querySelector<HTMLMetaElement>('meta[name="club-now"]')?.content
  if (!content) return 0

  const [datePart = '', timePart = '00:00:00'] = content.split('T')
  const [year = 1970, month = 1, day = 1] = datePart.split('-').map(Number)
  const [hour = 0, minute = 0, second = 0] = timePart.split(':').map(Number)
  const clubNowAtLoad = new Date(year, month - 1, day, hour, minute, second).getTime()
  return Number.isNaN(clubNowAtLoad) ? 0 : clubNowAtLoad - Date.now()
}

/** The club's current wall-clock time as a local Date — the way the calendars show club times. */
export function clubNow(): Date {
  offset ??= readOffset()
  return new Date(Date.now() + offset)
}
