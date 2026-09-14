<script setup lang="ts">
// Reserve a chosen tee time: players (never more than the places left), holes, optional names and
// notes, and add-ons. Priced by the server (GolfReservationRequest) as the form changes.
import { computed, ref, watch } from 'vue'
import BaseButton from '~/components/ui/BaseButton.vue'
import BaseModal from '~/components/ui/BaseModal.vue'
import { api, ApiError, errorMessage } from '~/lib/api'
import { longDateLabel } from '~/lib/dates'
import { formatRupiah } from '~/lib/money'
import type { GolfBookingProps, GolfQuote, GolfReservationCreated, TeeTimeSlot } from '~/types/api'

const props = defineProps<{
  open: boolean
  teeTime: TeeTimeSlot | null
  date: string
  course: GolfBookingProps['course']
  items: GolfBookingProps['items']
  quoteUrl: string
  reservationsUrl: string
}>()

const emit = defineEmits<{
  close: []
  /** The tee time filled up while the form was open; the tee sheet should reload. */
  taken: []
}>()

const QUOTE_DELAY_MS = 250

const players = ref(1)
const holes = ref(props.course.holesList[props.course.holesList.length - 1] ?? 18)
const playerNames = ref<string[]>([])
const notes = ref('')
const addOnIds = ref<number[]>([])
const quote = ref<GolfQuote | null>(null)
const quoting = ref(false)
const submitting = ref(false)
const error = ref('')

const maxPlayers = computed(() => Math.max(1, Math.min(props.course.maxPlayers, props.teeTime?.remaining ?? props.course.maxPlayers)))
const canSubmit = computed(() => !!quote.value?.bookable && !quoting.value && !submitting.value)

// A fresh tee time starts a fresh form, keeping only a party size that still fits.
watch(
  () => [props.open, props.teeTime] as const,
  ([open]) => {
    if (!open) return
    players.value = Math.min(players.value, maxPlayers.value)
    playerNames.value = []
    notes.value = ''
    addOnIds.value = []
    quote.value = null
    error.value = ''
  },
)

function payload() {
  return {
    tee_time: props.teeTime ? `${props.date} ${props.teeTime.time}` : null,
    players_count: players.value,
    holes: holes.value,
    player_names: playerNames.value.slice(0, players.value),
    notes: notes.value,
    add_on_ids: addOnIds.value,
  }
}

let quoteTimer: number | undefined
let quoteSequence = 0

watch(
  () => [props.open, props.teeTime, players.value, holes.value, addOnIds.value.join(',')] as const,
  ([open]) => {
    window.clearTimeout(quoteTimer)
    if (!open || !props.teeTime) return
    quoteTimer = window.setTimeout(() => void fetchQuote(), QUOTE_DELAY_MS)
  },
)

async function fetchQuote(): Promise<void> {
  const sequence = ++quoteSequence
  quoting.value = true
  try {
    const result = await api.post<GolfQuote>(props.quoteUrl, payload())
    if (sequence === quoteSequence) quote.value = result
  } catch (e) {
    if (sequence === quoteSequence) error.value = errorMessage(e, 'We could not price this tee time. Please try again.')
  } finally {
    if (sequence === quoteSequence) quoting.value = false
  }
}

async function reserve(): Promise<void> {
  if (!canSubmit.value) return
  submitting.value = true
  error.value = ''
  try {
    const created = await api.post<GolfReservationCreated>(props.reservationsUrl, payload())
    window.location.assign(created.redirect_url)
  } catch (e) {
    submitting.value = false
    error.value = errorMessage(e, 'We could not reserve this tee time. Please try again.')
    if (e instanceof ApiError && e.status === 409) emit('taken')
  }
}

function toggleAddOn(id: number, checked: boolean): void {
  addOnIds.value = checked ? [...addOnIds.value, id] : addOnIds.value.filter((existing) => existing !== id)
}
</script>

<template>
  <BaseModal :open="open" title="Book Tee Time" :dismissible="!submitting" @close="emit('close')">
    <div class="bbcc-modal-callout">
      <span class="bbcc-modal-label">Selected Tee Time</span>
      <span class="bbcc-modal-value" data-testid="selected-tee-time">
        {{ teeTime ? `${longDateLabel(date)} — ${teeTime.time}` : '—' }}
      </span>
    </div>

    <div class="bbcc-field">
      <label for="golf-players">Number of Players</label>
      <select id="golf-players" v-model.number="players">
        <option v-for="n in maxPlayers" :key="n" :value="n">{{ n }} {{ n === 1 ? 'Player' : 'Players' }}</option>
      </select>
    </div>

    <div class="bbcc-modal-group">
      <span class="bbcc-modal-label">Number of Holes</span>
      <div class="bbcc-radio-row">
        <label v-for="option in course.holesList" :key="option" class="bbcc-radio" :for="`golf-holes-${option}`">
          <input :id="`golf-holes-${option}`" v-model.number="holes" type="radio" name="golf-holes" :value="option">
          <span>{{ option }} Holes</span>
        </label>
      </div>
    </div>

    <div class="bbcc-field">
      <label :for="`golf-player-name-1`">Player Names <span class="golf-optional">(optional)</span></label>
      <input
        v-for="n in players"
        :id="`golf-player-name-${n}`"
        :key="n"
        v-model.trim="playerNames[n - 1]"
        class="golf-player-name"
        type="text"
        maxlength="60"
        :placeholder="`Player ${n}`"
      >
    </div>

    <div class="bbcc-field">
      <label for="golf-notes">Notes <span class="golf-optional">(optional)</span></label>
      <textarea id="golf-notes" v-model="notes" rows="2" maxlength="255"></textarea>
    </div>

    <div v-if="items.length" class="bbcc-modal-group">
      <span class="bbcc-modal-label">Add-ons</span>
      <label v-for="item in items" :key="item.id" class="golf-addon">
        <input
          type="checkbox"
          :checked="addOnIds.includes(item.id)"
          @change="toggleAddOn(item.id, ($event.target as HTMLInputElement).checked)"
        >
        <span>{{ item.name }}</span>
        <span class="golf-addon-price">{{ formatRupiah(item.price) }} / {{ item.perPerson ? 'player' : 'booking' }}</span>
      </label>
    </div>

    <div class="bbcc-modal-summary" :aria-busy="quoting" data-testid="golf-quote">
      <div class="bbcc-modal-summary-row">
        <span>Rate per player</span>
        <span>{{ quote?.rate_label ?? '—' }}</span>
      </div>
      <div class="bbcc-modal-summary-row">
        <span>Green fee</span>
        <span>{{ quote?.green_fee_label ?? '—' }}</span>
      </div>
      <div v-for="line in quote?.lines ?? []" :key="line.label" class="bbcc-modal-summary-row">
        <span>{{ line.label }}</span>
        <span>{{ line.amount_label }}</span>
      </div>
      <div class="bbcc-modal-summary-row bbcc-modal-summary-total">
        <span>Total</span>
        <span>{{ quote?.total_label ?? '—' }}</span>
      </div>
    </div>

    <p v-if="error || quote?.message" class="bbcc-field-error-text mb-0" role="alert">{{ error || quote?.message }}</p>

    <template #footer>
      <BaseButton variant="light" :disabled="submitting" @click="emit('close')">Cancel</BaseButton>
      <BaseButton :disabled="!canSubmit" :loading="submitting" data-testid="reserve-tee-time" @click="reserve">
        {{ submitting ? 'Reserving…' : 'Reserve Tee Time' }}
      </BaseButton>
    </template>
  </BaseModal>
</template>

<style scoped>
.golf-optional {
  color: var(--bbcc-ink-soft, #777);
  font-weight: 400;
}

.golf-player-name + .golf-player-name {
  margin-top: 8px;
}

.golf-addon {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px 10px;
  margin: 0 0 8px;
  cursor: pointer;
}

/* The site's theme sizes form inputs as full-width blocks; a checkbox here sits inline with its label. */
.golf-addon input[type='checkbox'] {
  display: inline-block;
  flex: 0 0 auto;
  width: 16px;
  height: 16px;
  margin: 0;
  padding: 0;
}

.golf-addon-price {
  color: var(--bbcc-ink-soft, #777);
  font-size: 13px;
}
</style>
