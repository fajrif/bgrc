<script setup lang="ts">
// The tee sheet for one date: every tee time, coloured by the places left. Today's sheet refreshes
// every minute, since its slots pass while the page is open.
import { onBeforeUnmount, ref, watch } from 'vue'
import { api, errorMessage } from '~/lib/api'
import type { TeeTimeSlot } from '~/types/api'

const props = withDefaults(
  defineProps<{
    date: string
    today: string
    url: string
    /** A known party size (moving a paid reservation): tee times without room for all of them can't be chosen. */
    players?: number
  }>(),
  { players: 1 },
)

const emit = defineEmits<{
  choose: [slot: TeeTimeSlot]
}>()

const REFRESH_INTERVAL_MS = 60_000

const slots = ref<TeeTimeSlot[] | null>(null)
const error = ref('')
let refreshTimer: number | undefined
let requestSequence = 0

async function load(): Promise<void> {
  const sequence = ++requestSequence
  error.value = ''
  try {
    const result = await api.get<TeeTimeSlot[]>(props.url, { date: props.date })
    if (sequence === requestSequence) slots.value = result
  } catch (e) {
    if (sequence === requestSequence) error.value = errorMessage(e, 'Error loading tee times. Please try again.')
  }
}

watch(
  () => props.date,
  () => {
    slots.value = null
    void load()
    window.clearInterval(refreshTimer)
    if (props.date === props.today) refreshTimer = window.setInterval(() => void load(), REFRESH_INTERVAL_MS)
  },
  { immediate: true },
)

onBeforeUnmount(() => window.clearInterval(refreshTimer))

defineExpose({ reload: load })

function tier(slot: TeeTimeSlot): number {
  return Math.min(slot.remaining, 4)
}
</script>

<template>
  <div class="bbcc-teetime-grid" data-testid="tee-time-grid">
    <p v-if="error" class="bbcc-teetime-note bbcc-teetime-note-error" role="alert">{{ error }}</p>
    <p v-else-if="slots === null" class="bbcc-teetime-note">
      <i class="fa-solid fa-circle-notch fa-spin" aria-hidden="true"></i>
      Loading available tee times…
    </p>
    <p v-else-if="slots.length === 0" class="bbcc-teetime-note">No tee times available for this date.</p>
    <div v-else class="row row-cols-2 row-cols-md-3 row-cols-lg-4 g-3">
      <div v-for="slot in slots" :key="slot.time" class="col">
        <span v-if="slot.past" class="bbcc-teeslot bbcc-teeslot-past" title="This tee time has already passed">{{ slot.time }}</span>
        <span
          v-else-if="!slot.available || slot.remaining < players"
          class="bbcc-teeslot bbcc-teeslot-booked"
          :title="slot.available ? `Not enough spots for ${players} players` : 'Fully booked'"
        >{{ slot.time }}</span>
        <button
          v-else
          type="button"
          class="bbcc-teeslot"
          :class="`bbcc-teeslot-remaining-${tier(slot)}`"
          :data-testid="`tee-${slot.time}`"
          @click="emit('choose', slot)"
        >
          {{ slot.time }}<br>
          <small class="fw-normal">{{ slot.remaining }} {{ slot.remaining === 1 ? 'spot' : 'spots' }} left</small>
        </button>
      </div>
    </div>
  </div>
</template>
