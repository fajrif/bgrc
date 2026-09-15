<script setup lang="ts">
// The week grid for one court. Drag across hours to choose a slot; the choice is drawn as its own
// event, which can be dragged or resized, and removed by clicking it. Taken hours come from the
// availability feed and cannot be selected over.
import FullCalendar from '@fullcalendar/vue3'
import interactionPlugin from '@fullcalendar/interaction'
import timeGridPlugin from '@fullcalendar/timegrid'
import type { CalendarOptions, EventInput } from '@fullcalendar/core'
import { computed } from 'vue'
import { clubNow } from '~/lib/clubClock'
import { addDays, hourLabel, hoursBetween, weekday } from '~/lib/dates'
import type { CourtAvailability } from '~/types/api'

const props = defineProps<{
  /** First day shown, "YYYY-MM-DD". The parent re-mounts the calendar when it changes. */
  date: string
  availability: CourtAvailability | null
  selection: { start: Date; end: Date } | null
  selectionTitle: string
  /** A fixed length in hours (a class session): only that length can be chosen, and it can't be resized. */
  hours?: number
}>()

const emit = defineEmits<{
  select: [start: Date, end: Date]
  clear: []
}>()

const SELECTION_ID = 'selection'

// A slot must end on the day it starts, cannot start before the club's current time (not the device's),
// and must be the fixed length if any.
function allowed(start: Date, end: Date): boolean {
  const lastMoment = new Date(end.getTime() - 1)
  const rightLength = props.hours === undefined || hoursBetween(start, end) === props.hours
  return rightLength && start.toDateString() === lastMoment.toDateString() && start.getTime() >= clubNow().getTime()
}

const events = computed<EventInput[]>(() => {
  const list: EventInput[] = [...(props.availability?.events ?? [])]
  if (props.selection) {
    list.push({
      id: SELECTION_ID,
      title: props.selectionTitle,
      start: props.selection.start,
      end: props.selection.end,
      editable: true,
      durationEditable: props.hours === undefined,
      backgroundColor: '#3a3a3a',
      borderColor: '#3a3a3a',
      textColor: '#ffffff',
    })
  }
  return list
})

const options = computed<CalendarOptions>(() => ({
  plugins: [timeGridPlugin, interactionPlugin],
  initialView: 'timeGridWeek',
  initialDate: props.date,
  // "Today" and the now-indicator follow the club's clock.
  now: () => clubNow(),
  firstDay: weekday(props.date),
  validRange: { start: props.date, end: addDays(props.date, 7) },
  headerToolbar: false,
  height: 'auto',
  allDaySlot: false,
  slotDuration: '01:00',
  slotMinTime: props.availability?.slot_min_time ?? '06:00',
  slotMaxTime: props.availability?.slot_max_time ?? '22:00',
  businessHours: props.availability?.business_hours ?? [],
  selectConstraint: 'businessHours',
  eventConstraint: 'businessHours',
  selectable: true,
  selectMirror: true,
  longPressDelay: 10,
  // Choosing again over the current choice replaces it; anything else already there blocks.
  selectOverlap: (event) => event.id === SELECTION_ID,
  eventOverlap: false,
  dayHeaderFormat: { weekday: 'short', month: 'numeric', day: 'numeric' },
  slotLabelContent: (arg) => hourLabel(arg.date),
  eventTimeFormat: { hour: '2-digit', minute: '2-digit', hour12: false },
  selectAllow: (span) => allowed(span.start, span.end),
  select: (arg) => {
    arg.view.calendar.unselect()
    emit('select', arg.start, arg.end)
  },
  eventChange: (arg) => {
    const { start, end } = arg.event
    if (arg.event.id === SELECTION_ID && start && end && allowed(start, end)) emit('select', start, end)
    else arg.revert()
  },
  eventClick: (arg) => {
    const props = arg.event.extendedProps
    if (arg.event.id === SELECTION_ID) {
      emit('clear')
    } else if (props.signUpUrl) {
      arg.jsEvent.preventDefault()
      window.open(props.signUpUrl, '_blank', 'noopener')
    } else if (props.classUrl) {
      arg.jsEvent.preventDefault()
      window.location.href = props.classUrl
    }
  },
  // Classes and open events are booked elsewhere, so they carry a "Sign up" affordance.
  eventDidMount: (arg) => {
    const { signUpUrl, classUrl } = arg.event.extendedProps
    if (!signUpUrl && !classUrl) return
    const frame = arg.el.querySelector('.fc-event-main-frame')
    if (!frame) return
    // A one-hour block is only 52px tall, so it drops the time line.
    if (arg.event.start && arg.event.end && arg.event.end.getTime() - arg.event.start.getTime() < 2 * 3_600_000) {
      arg.el.classList.add('fc-event-compact')
    }
    const hint = document.createElement('span')
    hint.className = 'fc-signup-hint'
    hint.textContent = 'Sign up'
    frame.appendChild(hint)
  },
  events: events.value,
}))
</script>

<template>
  <!-- #calendar: the page's responsive styles give the grid a minimum width on phones. -->
  <div id="calendar">
    <FullCalendar :options="options" />
  </div>
</template>
