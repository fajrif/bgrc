<script setup lang="ts">
// Everything a payment page does for an unpaid order: the countdown, Pay (policies, then checkout),
// Cancel, and for guests the sign-in / register / verify modal. Mounted by PaymentPanelHelper
// (`payment_panel`) on bookings, tee times, Grab & Go orders and class credit purchases alike.
import { computed, ref } from 'vue'
import AuthModal from './AuthModal.vue'
import DisclaimerModal from './DisclaimerModal.vue'
import PaymentCountdown from './PaymentCountdown.vue'
import BaseButton from '~/components/ui/BaseButton.vue'
import { api } from '~/lib/api'
import { submitRailsForm } from '~/lib/checkout'
import type { AuthUrls, Disclaimer, PayableStatus, PayableType, PaymentStatusResponse } from '~/types/api'

const props = defineProps<{
  type: PayableType
  orderId: string
  status: PayableStatus
  secondsRemaining: number
  signedIn: boolean
  statusUrl: string
  checkoutUrl: string
  cancelUrl: string | null
  backUrl: string
  backLabel: string
  disclaimer: Disclaimer
  auth: AuthUrls
}>()

const status = ref<PayableStatus>(props.status)
const seconds = ref(props.secondsRemaining)
const elapsed = ref(props.secondsRemaining <= 0)
const disclaimerOpen = ref(false)
const authOpen = ref(false)
const confirmingCancel = ref(false)

const payable = computed(() => status.value === 'unpaid' && !elapsed.value)

function applyStatus(next: PaymentStatusResponse): void {
  // Anything that is not "still waiting for payment" is best shown by the server-rendered page.
  if (next.status === 'paid' || next.status === 'cancelled' || next.status === 'needs_reschedule') {
    window.location.reload()
    return
  }
  status.value = next.status
  seconds.value = next.seconds_remaining
  elapsed.value = next.status !== 'unpaid' || next.seconds_remaining <= 0
}

// Reaching zero locally is only a guess: checkout may have extended the hold from another tab.
// Ask the server, a moment after ExpirePaymentJob has had its chance to run.
function onElapsed(): void {
  elapsed.value = true
  window.setTimeout(async () => {
    try {
      applyStatus(await api.get<PaymentStatusResponse>(props.statusUrl))
    } catch {
      // Stay on the expired state; the page is correct on the next load either way.
    }
  }, 1500)
}

function pay(): void {
  if (props.signedIn) disclaimerOpen.value = true
  else authOpen.value = true
}

function onWindowReset(nextSeconds: number): void {
  seconds.value = nextSeconds
  elapsed.value = false
}

function cancelOrder(): void {
  if (props.cancelUrl) submitRailsForm(props.cancelUrl, 'delete')
}

// Signed in: reload so the server-rendered page claims the order and Pay opens the policies.
function reload(): void {
  window.location.reload()
}
</script>

<template>
  <div class="payment-panel" data-testid="payment-panel">
    <template v-if="payable">
      <PaymentCountdown :seconds="seconds" :status-url="statusUrl" @status="applyStatus" @elapsed="onElapsed" />

      <div class="payment-panel-actions">
        <BaseButton block data-testid="pay-now" @click="pay">Pay Now</BaseButton>

        <template v-if="cancelUrl">
          <BaseButton v-if="!confirmingCancel" variant="light" block @click="confirmingCancel = true">Cancel</BaseButton>
          <div v-else class="payment-panel-confirm">
            <p class="text-medium mb-2">Cancel this order? Its slot is released straight away.</p>
            <div class="payment-panel-confirm-buttons">
              <BaseButton variant="light" size="sm" @click="confirmingCancel = false">Keep It</BaseButton>
              <BaseButton size="sm" @click="cancelOrder">Yes, Cancel</BaseButton>
            </div>
          </div>
        </template>
      </div>
    </template>

    <div v-else class="payment-panel-expired" role="status">
      <p class="text-medium mb-2"><strong>The time limit for payment has expired.</strong></p>
      <a :href="backUrl" class="bbcc-btn bbcc-btn-block">{{ backLabel }}</a>
    </div>

    <DisclaimerModal
      :open="disclaimerOpen"
      :disclaimer="disclaimer"
      :checkout-url="checkoutUrl"
      @close="disclaimerOpen = false"
      @expired="elapsed = true"
    />

    <AuthModal
      v-if="!signedIn"
      :open="authOpen"
      :auth="auth"
      :type="type"
      :order-id="orderId"
      @close="authOpen = false"
      @window-reset="onWindowReset"
      @authenticated="reload"
    />
  </div>
</template>

<style scoped>
.payment-panel {
  margin-top: 1.25rem;
}

.payment-panel-actions {
  display: grid;
  gap: 0.75rem;
  margin-top: 1rem;
}

.payment-panel-confirm {
  padding: 0.75rem;
  border: 1px solid var(--bbcc-line, #ddd);
  text-align: center;
}

.payment-panel-confirm-buttons {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
}

.payment-panel-expired {
  text-align: center;
}
</style>
