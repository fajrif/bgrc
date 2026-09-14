<script setup lang="ts">
// "Your Booking Details": the chosen slot, priced by the server (CourtBookingRequest).
import type { CourtQuote } from '~/types/api'

defineProps<{
  quote: CourtQuote | null
  loading: boolean
  hasSelection: boolean
}>()
</script>

<template>
  <p v-if="!hasSelection" class="bbcc-booking-hint">
    Click and drag the times you want on the calendar to build your booking.
  </p>
  <p v-else-if="!quote" class="bbcc-booking-hint">Checking the price&hellip;</p>
  <template v-else>
    <ul v-if="quote.total_label" class="bbcc-booking-summary" :aria-busy="loading" data-testid="booking-summary">
      <li>Court: {{ quote.court }}</li>
      <li>Date: {{ quote.date_label }}</li>
      <li>Duration: {{ quote.duration_label }}</li>
      <li>Court fee: {{ quote.court_fee_label }}</li>
      <li v-for="line in quote.lines" :key="line.label">{{ line.label }}: {{ line.amount_label }}</li>
      <li><strong>Total Price: {{ quote.total_label }}</strong></li>
    </ul>
    <p v-if="quote.message" class="bbcc-booking-hint bbcc-booking-hint-error" role="alert">{{ quote.message }}</p>
  </template>
</template>
