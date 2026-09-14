<script setup lang="ts">
// A new time for a late-paid court booking (users/late_reschedules#show): any court of the same sport and
// court type, for the same number of hours. It is already paid for, so nothing is priced; the hour is
// re-checked under a lock when confirming.
import { computed, ref, watch } from 'vue'
import ConfirmRescheduleModal from './ConfirmRescheduleModal.vue'
import SlotCalendar from '~/components/booking/SlotCalendar.vue'
import { api, errorMessage } from '~/lib/api'
import { addDays, slotLabel, toWallClock, weekRangeLabel } from '~/lib/dates'
import { useReschedule } from '~/lib/useReschedule'
import type { CourtAvailability, CourtRescheduleProps } from '~/types/api'

const props = defineProps<CourtRescheduleProps>()

const courtId = ref<number | null>(props.initialCourtId)
const date = ref(props.today)
const availability = ref<CourtAvailability | null>(null)
const availabilityError = ref('')
const selection = ref<{ start: Date; end: Date } | null>(null)
const confirmOpen = ref(false)
const { submitting, error, submit } = useReschedule(props.urls.reschedule)

const court = computed(() => props.courts.find((option) => option.id === courtId.value) ?? null)
const hoursLabel = computed(() => `${props.durationHours} ${props.durationHours === 1 ? 'hour' : 'hours'}`)
const rows = computed(() => [
  { label: 'Court', value: court.value?.name ?? '—' },
  { label: 'Date', value: selection.value ? slotLabel(selection.value.start) : '—' },
  { label: 'Duration', value: props.durationLabel },
])

async function loadAvailability(): Promise<void> {
  availabilityError.value = ''
  if (!courtId.value) {
    availability.value = null
    return
  }
  try {
    availability.value = await api.get<CourtAvailability>(props.urls.availability.replace('__COURT__', String(courtId.value)), {
      start: date.value,
      end: addDays(date.value, 7),
    })
  } catch (e) {
    availabilityError.value = errorMessage(e, 'We could not load this court’s calendar. Please refresh the page.')
  }
}

watch(
  [courtId, date],
  () => {
    selection.value = null
    error.value = ''
    void loadAvailability()
  },
  { immediate: true },
)

function onDateChange(event: Event): void {
  const value = (event.target as HTMLInputElement).value
  // Clearing the field is not a date; keep showing the current week.
  if (value) date.value = value
}

function onSelect(start: Date, end: Date): void {
  error.value = ''
  selection.value = { start, end }
}

async function confirm(): Promise<void> {
  if (!selection.value || !courtId.value) return
  const outcome = await submit({ court_id: courtId.value, start: toWallClock(selection.value.start) })
  if (outcome === 'moved') return
  confirmOpen.value = false
  if (outcome === 'taken') {
    selection.value = null
    void loadAvailability()
  }
}
</script>

<template>
  <div class="row gx-4 gx-lg-5">
    <div class="col-12 col-lg-8">
      <div class="bbcc-schedule-head">
        <div>
          <h2 class="bbcc-hub-heading bbcc-schedule-title">{{ court?.name ?? 'Choose a court' }}</h2>
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
            <select v-model="courtId" aria-label="Court">
              <option v-for="option in courts" :key="option.id" :value="option.id">{{ option.name }}</option>
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
          selection-title="New time"
          :hours="durationHours"
          @select="onSelect"
          @clear="selection = null"
        />
      </div>
      <div v-else class="bbcc-table-empty">
        <p>No courts are available to move this booking to. Please contact us and we'll arrange a new time.</p>
      </div>
    </div>

    <div class="col-12 col-lg-4">
      <aside class="bbcc-booking-panel">
        <h2 class="bbcc-hub-heading">Your New Time</h2>
        <p v-if="!selection" class="bbcc-booking-hint">Select {{ hoursLabel }} on the calendar.</p>

        <ul class="bbcc-booking-summary" data-testid="reschedule-selection">
          <li v-for="row in rows" :key="row.label">{{ row.label }}: {{ row.value }}</li>
          <li><strong>Price: already paid</strong></li>
        </ul>

        <p v-if="error" class="bbcc-booking-hint bbcc-booking-hint-error" role="alert">{{ error }}</p>
        <button
          type="button"
          class="bbcc-btn bbcc-btn-block"
          :class="{ disabled: !selection || submitting }"
          :disabled="!selection || submitting"
          data-testid="open-reschedule-confirm"
          @click="confirmOpen = true"
        >
          Confirm New Time
        </button>
      </aside>
    </div>
  </div>

  <ConfirmRescheduleModal :open="confirmOpen" :busy="submitting" :rows="rows" @close="confirmOpen = false" @confirm="confirm" />
</template>
