<script setup lang="ts">
// Another session for a late-paid prescheduled class whose session filled up: any upcoming session with
// room for the whole party. Places are re-checked under a lock when confirming.
import { computed, ref } from 'vue'
import ConfirmRescheduleModal from './ConfirmRescheduleModal.vue'
import { api } from '~/lib/api'
import { useReschedule } from '~/lib/useReschedule'
import type { ClassRescheduleProps, ClassSessionOption, ClassSessionsResponse } from '~/types/api'

const props = defineProps<ClassRescheduleProps>()

const sessions = ref<ClassSessionOption[]>(props.sessions)
const sessionStart = ref<string | null>(null)
const confirmOpen = ref(false)
const { submitting, error, submit } = useReschedule(props.urls.reschedule)

const session = computed(() => sessions.value.find((option) => option.start === sessionStart.value) ?? null)
const rows = computed(() => [
  { label: 'Class', value: props.className },
  { label: 'Session', value: session.value ? `${session.value.dateLabel}, ${session.value.startTime} – ${session.value.endTime}` : '—' },
  { label: 'Pax', value: `${props.pax} pax` },
])

// A session can fill up while the customer decides; show the places as they are now.
async function refreshSessions(): Promise<void> {
  try {
    sessions.value = (await api.get<ClassSessionsResponse>(props.urls.sessions)).sessions
    if (session.value === null || session.value.placesLeft < props.pax) sessionStart.value = null
  } catch {
    // The list on screen stays; confirming re-checks the places anyway.
  }
}

async function confirm(): Promise<void> {
  if (!sessionStart.value) return
  const outcome = await submit({ session_start: sessionStart.value })
  if (outcome === 'moved') return
  confirmOpen.value = false
  if (outcome === 'taken') void refreshSessions()
}
</script>

<template>
  <div class="bbcc-booking-panel">
    <h2 class="bbcc-hub-heading">Upcoming Sessions</h2>

    <p v-if="sessions.length === 0" class="bbcc-booking-hint">
      There are no upcoming sessions in the next 14 days. Please check back soon, or contact us and we'll arrange one for you.
    </p>

    <template v-else>
      <div class="mb-3" data-testid="reschedule-sessions">
        <div
          v-for="(option, index) in sessions"
          :key="option.start"
          class="d-flex align-items-center gap-2 mb-2"
          :class="{ 'text-muted': option.placesLeft < pax }"
        >
          <input
            :id="`reschedule-session-${index}`"
            v-model="sessionStart"
            class="class-reschedule-radio"
            type="radio"
            name="reschedule-session"
            :value="option.start"
            :disabled="option.placesLeft < pax"
          >
          <label :for="`reschedule-session-${index}`" class="class-reschedule-label">
            {{ option.dateLabel }} &middot; {{ option.startTime }} – {{ option.endTime }} &middot;
            <span v-if="option.placesLeft >= pax" class="text-success fw-semibold">{{ option.placesLeft }} places left</span>
            <span v-else-if="option.placesLeft > 0" class="text-danger">Only {{ option.placesLeft }} left</span>
            <span v-else class="text-danger">Full</span>
          </label>
        </div>
      </div>

      <p v-if="error" class="bbcc-booking-hint bbcc-booking-hint-error" role="alert">{{ error }}</p>
      <button
        type="button"
        class="bbcc-btn"
        :class="{ disabled: !session || submitting }"
        :disabled="!session || submitting"
        data-testid="open-reschedule-confirm"
        @click="confirmOpen = true"
      >
        Confirm New Session
      </button>
    </template>
  </div>

  <ConfirmRescheduleModal :open="confirmOpen" :busy="submitting" :rows="rows" @close="confirmOpen = false" @confirm="confirm" />
</template>

<style scoped>
/* The theme styles bare inputs as text fields; keep these as plain radio buttons. */
.class-reschedule-radio {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
  margin-bottom: 0;
}

.class-reschedule-label {
  margin: 0;
  cursor: pointer;
}
</style>
