<script setup lang="ts">
// Counts down an order's payment window. The seconds come from the database clock, and the server
// stays the authority: this re-syncs when the tab becomes visible again, when the page is restored
// from the back-forward cache, and every 15 seconds while visible. It never expires anything
// itself; ExpirePaymentJob does that at the deadline.
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { api } from '~/lib/api'
import type { PaymentStatusResponse } from '~/types/api'

const props = defineProps<{
  seconds: number
  statusUrl: string
}>()

const emit = defineEmits<{
  status: [PaymentStatusResponse]
  elapsed: []
}>()

const POLL_INTERVAL_MS = 15_000

// An absolute deadline rather than a decrementing counter, so a background tab whose timers were
// throttled still shows the right time when it comes back.
const deadline = ref(Date.now() + props.seconds * 1000)
const now = ref(Date.now())
let tickTimer: number | undefined
let pollTimer: number | undefined

const remaining = computed(() => Math.max(0, Math.ceil((deadline.value - now.value) / 1000)))
const display = computed(() => {
  const minutes = Math.floor(remaining.value / 60)
  const seconds = remaining.value % 60
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
})

function restart(seconds: number): void {
  deadline.value = Date.now() + seconds * 1000
  now.value = Date.now()
}

watch(() => props.seconds, restart)

watch(remaining, (value, previous) => {
  if (value === 0 && previous > 0) emit('elapsed')
})

async function sync(): Promise<void> {
  try {
    const status = await api.get<PaymentStatusResponse>(props.statusUrl)
    restart(status.seconds_remaining)
    emit('status', status)
  } catch {
    // A dropped request is not news; keep counting locally until the next sync.
  }
}

function onVisibilityChange(): void {
  if (document.visibilityState === 'visible') void sync()
}

function onPageShow(event: PageTransitionEvent): void {
  if (event.persisted) void sync()
}

onMounted(() => {
  tickTimer = window.setInterval(() => {
    now.value = Date.now()
  }, 1000)
  pollTimer = window.setInterval(() => {
    if (document.visibilityState === 'visible') void sync()
  }, POLL_INTERVAL_MS)
  document.addEventListener('visibilitychange', onVisibilityChange)
  window.addEventListener('pageshow', onPageShow)
})

onBeforeUnmount(() => {
  window.clearInterval(tickTimer)
  window.clearInterval(pollTimer)
  document.removeEventListener('visibilitychange', onVisibilityChange)
  window.removeEventListener('pageshow', onPageShow)
})
</script>

<template>
  <div class="bbcc-countdown" :class="{ 'bbcc-countdown-urgent': remaining <= 60 }" role="timer">
    <span class="bbcc-countdown-label">Time remaining to pay</span>
    <span class="bbcc-countdown-value" data-testid="countdown-value">{{ display }}</span>
    <span class="bbcc-countdown-note">Unpaid orders are released automatically.</span>
  </div>
</template>
