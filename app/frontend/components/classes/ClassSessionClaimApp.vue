<script setup lang="ts">
// Spending one paid class credit (class_credit_purchases#book_session): choose a court and week, pick the
// class's length on the calendar, choose a coach and claim. The session is already paid for, so there is
// no price and no payment window; the hour is re-checked under a lock when claiming.
import { computed, ref, watch } from 'vue'
import ClaimDisclaimerModal from './ClaimDisclaimerModal.vue'
import SlotCalendar from '~/components/booking/SlotCalendar.vue'
import { api, ApiError, errorMessage } from '~/lib/api'
import { addDays, slotLabel, toWallClock, weekRangeLabel } from '~/lib/dates'
import type { ClassSessionClaimed, ClassSessionClaimProps, CourtAvailability } from '~/types/api'

const props = defineProps<ClassSessionClaimProps>()

const courtTypeId = ref<number | null>(props.initialCourtTypeId)
const courtId = ref<number | null>(props.initialCourtId)
const date = ref(props.today)
const coachId = ref<number | null>(null)

const availability = ref<CourtAvailability | null>(null)
const availabilityError = ref('')
const selection = ref<{ start: Date; end: Date } | null>(null)
const disclaimerOpen = ref(false)
const submitting = ref(false)
const error = ref('')

const courtsOfType = computed(() => props.courts.filter((court) => court.courtTypeId === courtTypeId.value))
const court = computed(() => props.courts.find((option) => option.id === courtId.value) ?? null)
const hoursLabel = computed(() => `${props.groupClass.durationHours} ${props.groupClass.durationHours === 1 ? 'hour' : 'hours'}`)
const canSubmit = computed(() => selection.value !== null && coachId.value !== null && !submitting.value)

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

function onCourtTypeChange(): void {
  courtId.value = courtsOfType.value[0]?.id ?? null
}

function onDateChange(event: Event): void {
  const value = (event.target as HTMLInputElement).value
  // Clearing the field is not a date; keep showing the current week.
  if (value) date.value = value
}

function onSelect(start: Date, end: Date): void {
  error.value = ''
  selection.value = { start, end }
}

async function claim(): Promise<void> {
  if (!canSubmit.value || !selection.value) return
  submitting.value = true
  error.value = ''
  try {
    const claimed = await api.post<ClassSessionClaimed>(props.urls.claim, {
      court_id: courtId.value,
      coach_id: coachId.value,
      start: toWallClock(selection.value.start),
    })
    window.location.assign(claimed.redirect_url)
  } catch (e) {
    submitting.value = false
    disclaimerOpen.value = false
    error.value = errorMessage(e, 'We could not claim this session. Please try again.')
    // Taken while the customer was deciding: show the calendar as it is now.
    if (e instanceof ApiError && e.status === 409) {
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
            <select v-model="courtTypeId" aria-label="Court type" @change="onCourtTypeChange">
              <option v-for="type in courtTypes" :key="type.id" :value="type.id">{{ type.name }}</option>
            </select>
          </div>
          <div class="bbcc-schedule-control">
            <select v-model="courtId" aria-label="Court" :disabled="courtsOfType.length === 0">
              <option v-for="option in courtsOfType" :key="option.id" :value="option.id">{{ option.name }}</option>
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
          :selection-title="groupClass.name"
          :hours="groupClass.durationHours"
          @select="onSelect"
          @clear="selection = null"
        />
      </div>
      <div v-else class="bbcc-table-empty">
        <p>There are no courts of this type. Please choose another court type.</p>
      </div>
    </div>

    <div class="col-12 col-lg-4">
      <aside class="bbcc-booking-panel">
        <h2 class="bbcc-hub-heading">Your Booking Details</h2>
        <p v-if="!selection" class="bbcc-booking-hint">Select {{ hoursLabel }} on the calendar to choose your session.</p>

        <table class="table table-borderless mb-3" data-testid="claim-summary">
          <tbody>
            <tr>
              <td class="text-muted ps-0 claim-summary-label">Group Class</td>
              <td><strong>{{ groupClass.name }}</strong></td>
            </tr>
            <tr>
              <td class="text-muted ps-0">Court</td>
              <td>{{ court?.name ?? '—' }}</td>
            </tr>
            <tr>
              <td class="text-muted ps-0">Date</td>
              <td>{{ selection ? slotLabel(selection.start) : '—' }}</td>
            </tr>
            <tr>
              <td class="text-muted ps-0">Duration</td>
              <td>{{ groupClass.durationLabel }}</td>
            </tr>
            <tr>
              <td class="text-muted ps-0">Pax</td>
              <td>{{ pax }}</td>
            </tr>
          </tbody>
        </table>

        <label for="claim-coach" class="text-medium fw-bold mb-1 d-block">Select Coach</label>
        <select id="claim-coach" v-model="coachId" class="form-select mb-3">
          <option :value="null" disabled>Choose a coach</option>
          <option v-for="coach in coaches" :key="coach.id" :value="coach.id">{{ coach.name }}</option>
        </select>

        <p v-if="error" class="bbcc-booking-hint bbcc-booking-hint-error" role="alert">{{ error }}</p>
        <button
          type="button"
          class="bbcc-btn bbcc-btn-block"
          :class="{ disabled: !canSubmit }"
          :disabled="!canSubmit"
          data-testid="open-claim-disclaimer"
          @click="disclaimerOpen = true"
        >
          Submit
        </button>
      </aside>
    </div>
  </div>

  <ClaimDisclaimerModal :open="disclaimerOpen" :busy="submitting" @close="disclaimerOpen = false" @agree="claim" />
</template>

<style scoped>
.claim-summary-label {
  width: 40%;
}
</style>
