<script setup lang="ts">
// The My Bookings calendar view (users/bookings#calendar): a month of the customer's court bookings, class
// sessions and tee times from the calendar feed. Clicking one shows its details, with a link to its page.
import FullCalendar from '@fullcalendar/vue3'
import dayGridPlugin from '@fullcalendar/daygrid'
import type { CalendarOptions, EventClickArg } from '@fullcalendar/core'
import { ref } from 'vue'
import BaseModal from '~/components/ui/BaseModal.vue'
import { clubNow } from '~/lib/clubClock'
import type { ScheduleCalendarProps, ScheduleEventDetails } from '~/types/api'

const props = defineProps<ScheduleCalendarProps>()

const selected = ref<ScheduleEventDetails | null>(null)
const loadError = ref('')

function onEventClick(arg: EventClickArg): void {
  // Events carry their page as `url`; the popup links to it instead of leaving straight away.
  arg.jsEvent.preventDefault()
  selected.value = arg.event.extendedProps as ScheduleEventDetails
}

const options: CalendarOptions = {
  plugins: [dayGridPlugin],
  initialView: 'dayGridMonth',
  initialDate: props.today,
  // The highlighted "today" follows the club's clock, not the device's.
  now: () => clubNow(),
  headerToolbar: { left: 'prev,next today', center: 'title', right: '' },
  height: 'auto',
  navLinks: false,
  // FullCalendar adds ?start=&end= for the visible range.
  events: {
    url: props.eventsUrl,
    failure: () => {
      loadError.value = 'We could not load your bookings. Please refresh the page.'
    },
  },
  eventClick: onEventClick,
}
</script>

<template>
  <p v-if="loadError" class="bbcc-booking-hint bbcc-booking-hint-error" role="alert">{{ loadError }}</p>
  <div id="user-schedule-calendar" class="schedule-calendar">
    <FullCalendar :options="options" />
  </div>

  <BaseModal :open="selected !== null" title="Booking Details" @close="selected = null">
    <template v-if="selected">
      <div class="bbcc-modal-callout">
        <span class="bbcc-modal-label">Booking ID</span>
        <span class="bbcc-modal-value">{{ selected.orderId ?? '—' }}</span>
      </div>
      <div class="bbcc-modal-group" data-testid="schedule-details">
        <div class="bbcc-modal-summary-row"><span>Type</span><span>{{ selected.type }}</span></div>
        <div class="bbcc-modal-summary-row"><span>Date &amp; Time</span><span>{{ selected.dateLabel }}</span></div>
        <div class="bbcc-modal-summary-row"><span>{{ selected.subtitleLabel }}</span><span>{{ selected.subtitle ?? '—' }}</span></div>
        <div class="bbcc-modal-summary-row"><span>Status</span><span>{{ selected.statusLabel }}</span></div>
        <div class="bbcc-modal-summary-row"><span>{{ selected.paxLabel }}</span><span>{{ selected.pax ?? '—' }}</span></div>
        <div v-if="selected.priceLabel" class="bbcc-modal-summary-row bbcc-modal-summary-total">
          <span>Price</span><span>{{ selected.priceLabel }}</span>
        </div>
      </div>
    </template>

    <template #footer>
      <button type="button" class="bbcc-btn bbcc-btn-light" @click="selected = null">Close</button>
      <a v-if="selected?.detailUrl" :href="selected.detailUrl" class="bbcc-btn">View Full Details</a>
    </template>
  </BaseModal>
</template>

<style scoped>
/* Muted toolbar buttons instead of FullCalendar's default blue. */
.schedule-calendar :deep(.fc-button-primary) {
  background-color: #6c757d;
  border-color: #6c757d;
  color: #fff;
}

.schedule-calendar :deep(.fc-button-primary:hover) {
  background-color: #5a6268;
  border-color: #545b62;
  color: #fff;
}

.schedule-calendar :deep(.fc-button-primary:not(:disabled):active),
.schedule-calendar :deep(.fc-button-primary:not(:disabled).fc-button-active) {
  background-color: #495057;
  border-color: #42484e;
  color: #fff;
}

.schedule-calendar :deep(.fc-button-primary:focus) {
  box-shadow: 0 0 0 0.2rem rgba(108, 117, 125, 0.5);
}

.schedule-calendar :deep(.fc-event) {
  cursor: pointer;
}
</style>
