<script setup lang="ts">
// The public court booking page (search#index): pick a court type, court and week, drag a slot on the
// calendar, add extras, and book. Prices always come from the server, and the slot is re-checked
// under a lock when booking, so the sidebar can never promise something the booking won't honour.
import { computed, ref, watch } from 'vue'
import AddOnPicker from './AddOnPicker.vue'
import BookingSummary from './BookingSummary.vue'
import SlotCalendar from './SlotCalendar.vue'
import { api, ApiError, errorMessage } from '~/lib/api'
import { addDays, hoursBetween, toWallClock, weekRangeLabel } from '~/lib/dates'
import type { CourtAvailability, CourtBookingCreated, CourtBookingProps, CourtQuote } from '~/types/api'

const props = defineProps<CourtBookingProps>()

const QUOTE_DELAY_MS = 250

const courtTypeId = ref<number | null>(props.initialCourtTypeId)
const courtId = ref<number | null>(props.initialCourtId)
const date = ref(props.initialDate)

const availability = ref<CourtAvailability | null>(null)
const availabilityError = ref('')
const selection = ref<{ start: Date; end: Date } | null>(null)
const addOns = ref<Record<string, number>>({})
const quote = ref<CourtQuote | null>(null)
const quoting = ref(false)
const submitting = ref(false)
const submitError = ref('')

const courtsOfType = computed(() => props.courts.filter((court) => court.courtTypeId === courtTypeId.value))
const hours = computed(() => (selection.value ? hoursBetween(selection.value.start, selection.value.end) : 0))
const canSubmit = computed(() => !!quote.value?.bookable && !quoting.value && !submitting.value)

function courtUrl(template: string): string {
  return template.replace('__COURT__', String(courtId.value))
}

// The address keeps the visitor's choices, so a refresh or a shared link opens the same week and court.
function syncAddress(): void {
  const url = new URL(window.location.href)
  url.searchParams.set('date', date.value)
  if (courtTypeId.value) url.searchParams.set('court_type_id', String(courtTypeId.value))
  if (courtId.value) url.searchParams.set('court_id', String(courtId.value))
  window.history.replaceState(window.history.state, '', url)
}

async function loadAvailability(): Promise<void> {
  availabilityError.value = ''
  if (!courtId.value) {
    availability.value = null
    return
  }
  try {
    availability.value = await api.get<CourtAvailability>(courtUrl(props.urls.availability), {
      start: date.value,
      end: addDays(date.value, 7),
    })
  } catch (error) {
    availabilityError.value = errorMessage(error, 'We could not load this court’s calendar. Please refresh the page.')
  }
}

watch(
  [courtId, date],
  () => {
    selection.value = null
    quote.value = null
    submitError.value = ''
    syncAddress()
    void loadAvailability()
  },
  { immediate: true },
)

function onCourtTypeChange(): void {
  courtId.value = courtsOfType.value[0]?.id ?? null
}

function onDateChange(event: Event): void {
  const value = (event.target as HTMLInputElement).value
  // Clearing the field is not a date; keep showing the current week.
  if (value) date.value = value
}

function onSelect(start: Date, end: Date): void {
  submitError.value = ''
  selection.value = { start, end }
}

function bookingPayload() {
  return {
    start: selection.value ? toWallClock(selection.value.start) : null,
    duration: hours.value,
    add_ons: addOns.value,
  }
}

let quoteTimer: number | undefined
let quoteSequence = 0

watch(
  [selection, addOns],
  () => {
    window.clearTimeout(quoteTimer)
    if (!selection.value || !courtId.value) {
      quote.value = null
      return
    }
    quoteTimer = window.setTimeout(() => void fetchQuote(), QUOTE_DELAY_MS)
  },
  { deep: true },
)

async function fetchQuote(): Promise<void> {
  const sequence = ++quoteSequence
  quoting.value = true
  try {
    const result = await api.post<CourtQuote>(courtUrl(props.urls.quote), bookingPayload())
    if (sequence === quoteSequence) quote.value = result
  } catch (error) {
    if (sequence === quoteSequence) {
      quote.value = null
      submitError.value = errorMessage(error, 'We could not price this booking. Please try again.')
    }
  } finally {
    if (sequence === quoteSequence) quoting.value = false
  }
}

async function submit(): Promise<void> {
  if (!canSubmit.value) return
  submitting.value = true
  submitError.value = ''
  try {
    const created = await api.post<CourtBookingCreated>(courtUrl(props.urls.bookings), bookingPayload())
    window.location.assign(created.redirect_url)
  } catch (error) {
    submitting.value = false
    submitError.value = errorMessage(error, 'We could not create this booking. Please try again.')
    // Taken while the visitor was deciding: show the calendar as it is now.
    if (error instanceof ApiError && error.status === 409) {
      selection.value = null
      void loadAvailability()
    }
  }
}
</script>

<template>
  <div class="row gx-4 gx-lg-5">
    <div class="col-12 col-lg-8">
      <div class="bbcc-schedule-head">
        <div>
          <h1 class="bbcc-hub-heading bbcc-schedule-title">{{ sport.name }}</h1>
          <p class="bbcc-schedule-range">{{ weekRangeLabel(date) }}</p>
        </div>
        <div class="bbcc-schedule-filters">
          <div class="bbcc-schedule-control bbcc-schedule-control-date">
            <input type="date" aria-label="Date" :value="date" :min="today" :max="maxDate" @change="onDateChange">
          </div>
        </div>
      </div>

      <div class="bbcc-schedule-bar">
        <div class="bbcc-schedule-legend">
          <span><i class="bbcc-legend-swatch bbcc-legend-selection"></i>Your Selection</span>
          <span><i class="bbcc-legend-swatch bbcc-legend-booked"></i>Booked</span>
          <span><i class="bbcc-legend-swatch bbcc-legend-blocked"></i>Blocked Event</span>
        </div>
        <div class="bbcc-schedule-filters">
          <div class="bbcc-schedule-control">
            <select v-model.number="courtTypeId" aria-label="Court type" @change="onCourtTypeChange">
              <option v-for="type in courtTypes" :key="type.id" :value="type.id">{{ type.name }}</option>
            </select>
          </div>
          <div class="bbcc-schedule-control">
            <select v-model.number="courtId" aria-label="Court" :disabled="courtsOfType.length === 0">
              <option v-for="court in courtsOfType" :key="court.id" :value="court.id">{{ court.name }}</option>
            </select>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="row g-4 g-lg-5">
    <div class="col-12 col-lg-8">
      <p v-if="availabilityError" class="bbcc-booking-hint bbcc-booking-hint-error" role="alert">{{ availabilityError }}</p>
      <div v-if="courtId" id="schedule" class="bbcc-schedule">
        <SlotCalendar
          :key="`${courtId}-${date}`"
          :date="date"
          :availability="availability"
          :selection="selection"
          :selection-title="quote?.event_title ?? 'Checking price…'"
          @select="onSelect"
          @clear="selection = null"
        />
      </div>
      <div v-else class="bbcc-table-empty">
        <p>Sorry, there are no courts of this type yet. Please choose another court type.</p>
      </div>
    </div>

    <div class="col-12 col-lg-4">
      <aside class="bbcc-booking-panel">
        <h2 class="bbcc-hub-heading">Your Booking Details</h2>

        <BookingSummary :quote="quote" :loading="quoting" :has-selection="selection !== null" />
        <AddOnPicker v-if="items.length" v-model="addOns" :items="items" />

        <p v-if="submitError" class="bbcc-booking-hint bbcc-booking-hint-error" role="alert">{{ submitError }}</p>
        <button
          type="button"
          class="bbcc-btn"
          :class="{ disabled: !canSubmit }"
          :disabled="!canSubmit"
          data-testid="submit-booking"
          @click="submit"
        >
          {{ submitting ? 'Booking…' : 'Submit' }}
        </button>

        <p class="bbcc-booking-note">
          Booking window: Online bookings are available up to 14 days in advance.
          Need a booking outside regular hours or beyond 14 days?
          <br>
          <a :href="whatsappUrl" target="_blank" rel="noopener">Contact us via WhatsApp</a>.
        </p>
      </aside>
    </div>
  </div>
</template>
