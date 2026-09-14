// Booking times are wall-clock values with no time zone: the server stores and returns
// "YYYY-MM-DD HH:MM" meaning club time, and the calendar treats them as local times. Keep every
// conversion here so nothing slips a UTC offset in.

const pad = (value: number): string => String(value).padStart(2, '0')

/** "YYYY-MM-DD" from a local Date. */
export function toDateString(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`
}

/** "YYYY-MM-DD HH:MM" from a local Date — the format the booking API reads. */
export function toWallClock(date: Date): string {
  return `${toDateString(date)} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

/** A local Date at midnight from "YYYY-MM-DD". */
export function parseDateString(value: string): Date {
  const [year = 1970, month = 1, day = 1] = value.split('-').map(Number)
  return new Date(year, month - 1, day)
}

export function addDays(value: string, days: number): string {
  const date = parseDateString(value)
  date.setDate(date.getDate() + days)
  return toDateString(date)
}

export function weekday(value: string): number {
  return parseDateString(value).getDay()
}

export function hoursBetween(start: Date, end: Date): number {
  return Math.round((end.getTime() - start.getTime()) / 3_600_000)
}

const SHORT_DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

/** "Mon 9/14/26 - Sun 9/20/26" for the seven days starting at `value`, as the page has always shown. */
export function weekRangeLabel(value: string): string {
  const format = (date: Date) =>
    `${SHORT_DAYS[date.getDay()]} ${date.getMonth() + 1}/${date.getDate()}/${String(date.getFullYear()).slice(-2)}`
  return `${format(parseDateString(value))} - ${format(parseDateString(addDays(value, 6)))}`
}

/** "Wednesday, September 16, 2026" for "2026-09-16". */
export function longDateLabel(value: string): string {
  return parseDateString(value).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

/** "08.00" slot labels, as the page has always shown. */
export function hourLabel(date: Date): string {
  return `${pad(date.getHours())}.${pad(date.getMinutes())}`
}
