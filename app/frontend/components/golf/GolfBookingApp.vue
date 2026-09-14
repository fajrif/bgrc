<script setup lang="ts">
// The golf booking page (golf#index): pick a date, choose a tee time from the sheet, then reserve it
// with players, holes and add-ons. The server prices the form and re-checks capacity under a lock.
import { ref } from 'vue'
import GolfReservationModal from './GolfReservationModal.vue'
import TeeTimeGrid from './TeeTimeGrid.vue'
import type { GolfBookingProps, TeeTimeSlot } from '~/types/api'

const props = defineProps<GolfBookingProps>()

const date = ref(props.today)
const chosen = ref<TeeTimeSlot | null>(null)
const formOpen = ref(false)
const grid = ref<InstanceType<typeof TeeTimeGrid> | null>(null)

function onDateChange(event: Event): void {
  const value = (event.target as HTMLInputElement).value
  // Clearing the field is not a date; keep showing the current sheet.
  if (value) date.value = value
}

function choose(slot: TeeTimeSlot): void {
  chosen.value = slot
  formOpen.value = true
}

function onTaken(): void {
  void grid.value?.reload()
}
</script>

<template>
  <div class="bbcc-teetime-card">
    <h2 class="bbcc-teetime-title">Select Your Tee Time</h2>

    <div class="bbcc-teetime-datefield">
      <label for="golf-date">Select Date</label>
      <input id="golf-date" type="date" :value="date" :min="today" :max="maxDate" @change="onDateChange">
    </div>

    <TeeTimeGrid ref="grid" :date="date" :today="today" :url="urls.teeTimes" @choose="choose" />

    <div class="bbcc-teetime-legend">
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-4"></i>4 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-3"></i>3 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-2"></i>2 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-1"></i>1 Left</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-booked"></i>Booked</span>
      <span><i class="bbcc-teetime-swatch bbcc-teetime-swatch-past"></i>Passed</span>
    </div>
  </div>

  <GolfReservationModal
    :open="formOpen"
    :tee-time="chosen"
    :date="date"
    :course="course"
    :items="items"
    :quote-url="urls.quote"
    :reservations-url="urls.reservations"
    @close="formOpen = false"
    @taken="onTaken"
  />
</template>
