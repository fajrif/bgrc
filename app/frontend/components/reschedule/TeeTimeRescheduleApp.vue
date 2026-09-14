<script setup lang="ts">
// A new tee time for a late-paid reservation: the same course, party and holes, on any tee time with room
// for the whole party. It is already paid for, so nothing is priced; capacity is re-checked under a lock
// when confirming.
import { computed, ref } from 'vue'
import ConfirmRescheduleModal from './ConfirmRescheduleModal.vue'
import TeeTimeGrid from '~/components/golf/TeeTimeGrid.vue'
import { longDateLabel } from '~/lib/dates'
import { useReschedule } from '~/lib/useReschedule'
import type { TeeTimeRescheduleProps, TeeTimeSlot } from '~/types/api'

const props = defineProps<TeeTimeRescheduleProps>()

const date = ref(props.today)
const chosen = ref<TeeTimeSlot | null>(null)
const confirmOpen = ref(false)
const grid = ref<InstanceType<typeof TeeTimeGrid> | null>(null)
const { submitting, error, submit } = useReschedule(props.urls.reschedule)

const rows = computed(() => [
  { label: 'Tee Time', value: chosen.value ? `${longDateLabel(date.value)}, ${chosen.value.time}` : '—' },
  { label: 'Course', value: props.courseName },
  { label: 'Players', value: String(props.players) },
  { label: 'Holes', value: props.holesLabel },
])

function onDateChange(event: Event): void {
  const value = (event.target as HTMLInputElement).value
  // Clearing the field is not a date; keep showing the current sheet.
  if (value) date.value = value
}

function choose(slot: TeeTimeSlot): void {
  error.value = ''
  chosen.value = slot
  confirmOpen.value = true
}

async function confirm(): Promise<void> {
  if (!chosen.value) return
  const outcome = await submit({ tee_time: `${date.value} ${chosen.value.time}` })
  if (outcome === 'moved') return
  confirmOpen.value = false
  if (outcome === 'taken') {
    chosen.value = null
    void grid.value?.reload()
  }
}
</script>

<template>
  <div class="bbcc-teetime-card">
    <h2 class="bbcc-teetime-title">Select Your New Tee Time</h2>
    <p class="bbcc-teetime-note">Only tee times with room for all {{ players }} {{ players === 1 ? 'player' : 'players' }} can be chosen.</p>

    <div class="bbcc-teetime-datefield">
      <label for="reschedule-golf-date">Select Date</label>
      <input id="reschedule-golf-date" type="date" :value="date" :min="today" :max="maxDate" @change="onDateChange">
    </div>

    <p v-if="error" class="bbcc-teetime-note bbcc-teetime-note-error" role="alert">{{ error }}</p>
    <TeeTimeGrid ref="grid" :date="date" :today="today" :url="urls.teeTimes" :players="players" @choose="choose" />

    <div class="bbcc-teetime-legend">
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-4"></i>4 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-3"></i>3 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-2"></i>2 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-1"></i>1 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-booked"></i>Booked</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-past"></i>Passed</span>
    </div>
  </div>

  <ConfirmRescheduleModal :open="confirmOpen" :busy="submitting" :rows="rows" @close="confirmOpen = false" @confirm="confirm" />
</template>
