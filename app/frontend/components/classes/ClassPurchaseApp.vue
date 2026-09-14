<script setup lang="ts">
// The registration panel on a group class page (group_classes#show). A prescheduled class sells places in
// one upcoming session; any other class sells a pack of credits to spend later. Prices arrive with the
// page, priced by the same ClassCreditPurchaseRequest that saves the purchase, and places are re-checked
// under a lock when buying.
import { computed, ref } from 'vue'
import ClassPurchaseConfirm from './ClassPurchaseConfirm.vue'
import { api, ApiError, errorMessage } from '~/lib/api'
import { formatRupiah } from '~/lib/money'
import type { ClassCreditPurchaseCreated, ClassPurchaseProps, ClassSessionOption, ClassSessionsResponse } from '~/types/api'

const props = defineProps<ClassPurchaseProps>()

const sessions = ref<ClassSessionOption[]>(props.sessions)
const sessionStart = ref<string | null>(null)
const sessionsCount = ref(props.packs[0]?.sessions ?? 1)
const pax = ref(props.groupClass.minPax)
const confirmOpen = ref(false)
const submitting = ref(false)
const error = ref('')

const paxOptions = computed(() =>
  Array.from({ length: props.groupClass.maxPax - props.groupClass.minPax + 1 }, (_, index) => props.groupClass.minPax + index),
)
const pack = computed(() => props.packs.find((option) => option.sessions === sessionsCount.value) ?? props.packs[0])
const session = computed(() => sessions.value.find((option) => option.start === sessionStart.value) ?? null)
const tooManyPeople = computed(() => session.value !== null && pax.value > session.value.placesLeft)
const total = computed(() => priceFor(sessionsCount.value))
const canBuy = computed(
  () => !submitting.value && (!props.groupClass.prescheduled || (session.value !== null && !tooManyPeople.value)),
)
const sessionLabel = computed(() =>
  session.value ? `${session.value.dateLabel}, ${session.value.startTime} – ${session.value.endTime}` : null,
)

function priceFor(count: number): number {
  return props.prices[`${count}-${pax.value}`] ?? 0
}

function paxLabel(count: number): string {
  if (count === props.groupClass.minPax) return `${count} pax (Minimum)`
  if (count === props.groupClass.maxPax) return `${count} pax (Maximum)`
  return `${count} pax`
}

// A session can fill up while the visitor decides; show the places as they are now.
async function refreshSessions(): Promise<void> {
  try {
    sessions.value = (await api.get<ClassSessionsResponse>(props.urls.sessions)).sessions
    if (session.value === null || session.value.placesLeft === 0) sessionStart.value = null
  } catch {
    // The list on screen stays; buying re-checks the places anyway.
  }
}

async function purchase(): Promise<void> {
  if (!canBuy.value) return
  submitting.value = true
  error.value = ''
  try {
    const created = await api.post<ClassCreditPurchaseCreated>(props.urls.purchases, {
      group_class_id: props.groupClass.id,
      sessions_count: sessionsCount.value,
      pax: pax.value,
      session_start: sessionStart.value,
    })
    // Leaving for the payment page: stay busy so nothing is bought twice.
    window.location.assign(created.redirect_url)
  } catch (e) {
    submitting.value = false
    confirmOpen.value = false
    error.value = errorMessage(e, 'We could not register you for this class. Please try again.')
    if (e instanceof ApiError && e.status === 409) void refreshSessions()
  }
}
</script>

<template>
  <div class="card border-1 p-4">
    <h6 class="alt-font text-extra-dark-gray mb-3">Register for this Class</h6>

    <div v-if="groupClass.prescheduled && sessions.length === 0" class="alert alert-info mb-0">
      No upcoming sessions scheduled for this class in the next 14 days.
    </div>

    <template v-else>
      <template v-if="groupClass.prescheduled">
        <p class="fw-bold mb-2">Upcoming Sessions</p>
        <div class="mb-3" data-testid="class-sessions">
          <div
            v-for="(option, index) in sessions"
            :key="option.start"
            class="d-flex align-items-center gap-2 mb-2"
            :class="{ 'text-muted': option.placesLeft === 0 }"
          >
            <input
              :id="`class-session-${index}`"
              v-model="sessionStart"
              class="class-purchase-radio"
              type="radio"
              name="class-session"
              :value="option.start"
              :disabled="option.placesLeft === 0"
            >
            <label :for="`class-session-${index}`" class="class-purchase-label">
              {{ option.dateLabel }} &middot; {{ option.startTime }} – {{ option.endTime }} &middot;
              <span v-if="option.placesLeft > 0" class="text-success fw-semibold">
                {{ option.placesLeft }} / {{ groupClass.maxPax }} slots available
              </span>
              <span v-else class="text-danger">Full</span>
            </label>
          </div>
        </div>
      </template>

      <template v-if="packs.length > 1">
        <p class="fw-bold mb-2">Choose Pack Size</p>
        <div class="mb-3" data-testid="class-packs">
          <div v-for="option in packs" :key="option.sessions" class="d-flex align-items-center gap-2 mb-2">
            <input
              :id="`class-pack-${option.sessions}`"
              v-model="sessionsCount"
              class="class-purchase-radio"
              type="radio"
              name="class-pack"
              :value="option.sessions"
            >
            <label :for="`class-pack-${option.sessions}`" class="class-purchase-label">
              {{ option.label }} — {{ formatRupiah(priceFor(option.sessions)) }}
            </label>
          </div>
        </div>
      </template>

      <template v-if="paxOptions.length > 1">
        <label for="class-pax" class="fw-bold mb-2 d-block">Number of Pax</label>
        <select id="class-pax" v-model="pax" class="form-select mb-3">
          <option v-for="count in paxOptions" :key="count" :value="count">{{ paxLabel(count) }}</option>
        </select>
      </template>
      <p v-if="tooManyPeople" class="text-danger small mb-3" role="alert">
        Not enough slots available for this pax count on the selected date.
      </p>

      <div class="d-flex justify-content-between align-items-center mb-3 p-3 bg-light rounded">
        <span class="text-medium text-small">Total Price</span>
        <strong class="alt-font" data-testid="class-total">{{ formatRupiah(total) }}</strong>
      </div>

      <p v-if="!groupClass.prescheduled && pack" class="text-muted small mb-3">
        Credits valid for {{ pack.validity }} from payment date.
      </p>
      <p v-if="error" class="text-danger small mb-3" role="alert">{{ error }}</p>

      <button
        type="button"
        class="btn btn-dark w-100 text-uppercase letter-spacing-1 text-extra-small text-white"
        :disabled="!canBuy"
        data-testid="open-class-confirm"
        @click="confirmOpen = true"
      >
        Register &amp; Buy Credits
      </button>
      <p v-if="groupClass.prescheduled && !session" class="text-muted small mt-2 mb-0">Select a session above to continue.</p>
    </template>
  </div>

  <ClassPurchaseConfirm
    :open="confirmOpen"
    :busy="submitting"
    :class-name="groupClass.name"
    :session-label="groupClass.prescheduled ? sessionLabel : null"
    :pack-label="pack?.label ?? ''"
    :pax-label="`${pax} pax`"
    :total-label="formatRupiah(total)"
    :validity="groupClass.prescheduled ? null : (pack?.validity ?? null)"
    :payment-window-minutes="paymentWindowMinutes"
    @close="confirmOpen = false"
    @confirm="purchase"
  />
</template>

<style scoped>
/* The theme styles bare inputs as text fields; keep these as plain radio buttons. */
.class-purchase-radio {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
  margin-bottom: 0;
}

.class-purchase-label {
  margin: 0;
  cursor: pointer;
}
</style>
