<script setup>
import { computed, onMounted, ref, watch } from 'vue'

const props = defineProps({
  courtId: { type: String, required: true },
  courtTypeId: { type: String, required: true },
  courtTypes: { type: String, required: true },
  courts: { type: String, required: true },
  date: { type: String, required: true },
  businessHours: { type: String, required: true },
  events: { type: String, required: true },
  minOpenTime: { type: String, required: true },
  maxOpenTime: { type: String, required: true },
})

const courtTypes = JSON.parse(props.courtTypes)
const courts = JSON.parse(props.courts)

const courtTypeId = ref(Number(props.courtTypeId))
const courtId = ref(Number(props.courtId))
const date = ref(props.date)

const calendarEl = ref(null)
const priceInfo = ref(null)
const checking = ref(false)
let calendar = null
let tentativeEvent = null

const courtsOfType = computed(() => courts.filter((c) => c.courtTypeId === courtTypeId.value))

function pad(n) {
  return String(n).padStart(2, '0')
}

function toServerDateString(d) {
  return `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

function toISODate(d) {
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

function addDays(dateStr, days) {
  const d = new Date(dateStr)
  d.setDate(d.getDate() + days)
  return toISODate(d)
}

const today = toISODate(new Date())
const maxDate = addDays(today, 14)

const weekdayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
function formatRangeDate(d) {
  return `${weekdayShort[d.getDay()]} ${d.getMonth() + 1}/${d.getDate()}/${String(d.getFullYear()).slice(-2)}`
}
const weekRangeLabel = computed(() => {
  const start = new Date(date.value)
  const end = new Date(start)
  end.setDate(end.getDate() + 6)
  return `${formatRangeDate(start)} - ${formatRangeDate(end)}`
})

function isCrossDay(arg) {
  const startDay = new Date(arg.start.getFullYear(), arg.start.getMonth(), arg.start.getDate())
  const endDay = new Date(arg.end.getFullYear(), arg.end.getMonth(), arg.end.getDate())
  return startDay.getTime() === endDay.getTime()
}

// Writes into the still-legacy submit form (search/_search_results.html.erb). court-id and date
// must track the picker, or Submit could create the booking against the WRONG court/date.
function syncLegacyForm(start, duration, bookable) {
  const bookInput = document.getElementById('input-book')
  const durationInput = document.getElementById('input-duration')
  const submitBtn = document.getElementById('btnSubmit')
  const courtIdInput = document.getElementById('court-id')
  const dateInput = document.getElementById('date')
  if (bookInput) bookInput.value = start ? toServerDateString(start) : ''
  if (durationInput) durationInput.value = start ? String(duration) : ''
  if (submitBtn) {
    submitBtn.disabled = !bookable
    submitBtn.classList.toggle('disabled', !bookable)
  }
  if (courtIdInput) courtIdInput.value = String(courtId.value)
  if (dateInput) dateInput.value = date.value
}

async function checkPrice(start, end) {
  const duration = Math.round((end - start) / 3600000)
  checking.value = true
  try {
    const url = `/courts/${courtId.value}/calculate_price?` + new URLSearchParams({
      dates: toServerDateString(start),
      duration: String(duration),
      court_type: '0',
    })
    const response = await fetch(url, { headers: { Accept: 'application/json' } })
    priceInfo.value = await response.json()
    if (tentativeEvent) tentativeEvent.setProp('title', priceInfo.value.event_title)
    syncLegacyForm(start, duration, priceInfo.value.bookable)
  } finally {
    checking.value = false
  }
}

function onSelect(arg) {
  if (!isCrossDay(arg)) {
    calendar.unselect()
    return
  }
  if (tentativeEvent) tentativeEvent.remove()
  tentativeEvent = calendar.addEvent({
    id: 'book1',
    title: 'Checking price…',
    start: arg.start,
    end: arg.end,
    textColor: '#ffffff',
    borderColor: '#3a3a3a',
    color: '#3a3a3a',
  })
  void checkPrice(arg.start, arg.end)
  calendar.unselect()
}

function onEventClick(arg) {
  if (arg.event.id !== 'book1') return
  arg.event.remove()
  tentativeEvent = null
  priceInfo.value = null
  syncLegacyForm(null, 0, false)
}

function onEventChange(changeInfo) {
  if (changeInfo.event.id !== 'book1') return
  if (isCrossDay(changeInfo.event) && changeInfo.event.start >= new Date()) {
    if (changeInfo.event.title === changeInfo.oldEvent.title) {
      tentativeEvent = changeInfo.event
      void checkPrice(changeInfo.event.start, changeInfo.event.end)
    }
  } else {
    changeInfo.revert()
  }
}

function onCourtTypeChange() {
  courtId.value = courtsOfType.value[0]?.id ?? null
}

function syncAddress() {
  const url = new URL(window.location.href)
  url.searchParams.set('court_type_id', String(courtTypeId.value))
  if (courtId.value) url.searchParams.set('court_id', String(courtId.value))
  url.searchParams.set('date', date.value)
  window.history.replaceState(null, '', url)
}

let fetchSeq = 0
async function reloadSchedule() {
  if (!courtId.value || !calendar) return
  const seq = ++fetchSeq
  const response = await fetch(`/courts/${courtId.value}/schedule?start=${date.value}`, {
    headers: { Accept: 'application/json' },
  })
  const data = await response.json()
  if (seq !== fetchSeq) return // a newer change already started a fresher request

  if (tentativeEvent) {
    tentativeEvent.remove()
    tentativeEvent = null
  }
  priceInfo.value = null
  syncLegacyForm(null, 0, false)

  calendar.gotoDate(date.value)
  calendar.setOption('validRange', { start: date.value, end: addDays(date.value, 7) })
  calendar.setOption('businessHours', data.business_hours)
  calendar.setOption('events', data.events)
  calendar.setOption('slotMinTime', data.min_open_time)
  calendar.setOption('slotMaxTime', data.max_open_time)

  syncAddress()
}

watch([courtId, date], reloadSchedule)

onMounted(() => {
  calendar = new FullCalendar.Calendar(calendarEl.value, {
    headerToolbar: false,
    initialView: 'timeGridWeek',
    initialDate: date.value,
    firstDay: new Date(date.value).getDay(),
    navLinks: false,
    selectable: true,
    selectAllow: (arg) => isCrossDay(arg) && arg.start >= new Date(),
    validRange: { start: date.value, end: addDays(date.value, 7) },
    eventLongPressDelay: 10,
    dayHeaderFormat: { weekday: 'short', month: 'numeric', day: 'numeric' },
    eventTimeFormat: { hour: '2-digit', minute: '2-digit', hour12: false },
    selectMirror: true,
    allDaySlot: false,
    selectOverlap: false,
    eventOverlap: false,
    slotDuration: '01:00',
    slotMinTime: props.minOpenTime,
    slotMaxTime: props.maxOpenTime,
    editable: true,
    dayMaxEvents: false,
    selectConstraint: 'businessHours',
    eventConstraint: 'businessHours',
    businessHours: JSON.parse(props.businessHours),
    events: JSON.parse(props.events),
    select: onSelect,
    eventClick: onEventClick,
    eventChange: onEventChange,
  })
  calendar.setOption('height', 'auto')
  calendar.render()
})
</script>

<template>
  <Teleport to="#schedule-range">{{ weekRangeLabel }}</Teleport>

  <Teleport to="#schedule-date-control">
    <input type="date" v-model="date" :min="today" :max="maxDate" aria-label="Date">
  </Teleport>

  <Teleport to="#schedule-court-type-control">
    <select v-model.number="courtTypeId" aria-label="Court type" @change="onCourtTypeChange">
      <option v-for="type in courtTypes" :key="type.id" :value="type.id">{{ type.name }}</option>
    </select>
  </Teleport>

  <Teleport to="#schedule-court-control">
    <select v-model.number="courtId" aria-label="Court" :disabled="courtsOfType.length === 0">
      <option v-for="court in courtsOfType" :key="court.id" :value="court.id">{{ court.name }}</option>
    </select>
  </Teleport>

  <div class="bbcc-schedule" id="schedule">
    <div ref="calendarEl" id="calendar"></div>
  </div>

  <Teleport to="#calculate_table">
    <p v-if="checking" class="bbcc-booking-hint">Checking price…</p>
    <p v-else-if="!priceInfo" class="bbcc-booking-hint">Click and drag the times you want on the calendar to build your booking.</p>
    <p v-else-if="!priceInfo.bookable" class="bbcc-booking-hint bbcc-booking-hint-error">{{ priceInfo.message }}</p>
    <ul v-else class="bbcc-booking-summary">
      <li>Court: {{ priceInfo.court }}</li>
      <li>Date: {{ priceInfo.date_label }}</li>
      <li>Duration: {{ priceInfo.duration_label }}</li>
      <li>Total Price: {{ priceInfo.price_label }}</li>
    </ul>
  </Teleport>
</template>
