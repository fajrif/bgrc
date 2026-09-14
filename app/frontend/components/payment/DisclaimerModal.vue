<script setup lang="ts">
// The policies shown before paying, then the hand-off to the gateway. One component for every product;
// the wording comes from admin-managed snippets (PaymentPanelHelper#payment_disclaimer).
import { ref } from 'vue'
import BaseButton from '~/components/ui/BaseButton.vue'
import BaseModal from '~/components/ui/BaseModal.vue'
import { ApiError } from '~/lib/api'
import { startCheckout } from '~/lib/checkout'
import type { Disclaimer } from '~/types/api'

const props = defineProps<{
  open: boolean
  disclaimer: Disclaimer
  checkoutUrl: string
}>()

const emit = defineEmits<{
  close: []
  /** The server says the window has closed (HTTP 410); the panel shows the expired state. */
  expired: []
}>()

const busy = ref(false)
const error = ref('')

async function agreeAndPay(): Promise<void> {
  busy.value = true
  error.value = ''
  try {
    await startCheckout(props.checkoutUrl)
    // Leaving for the gateway: keep the button busy so it cannot be pressed twice.
  } catch (e) {
    busy.value = false
    if (e instanceof ApiError && e.status === 410) {
      emit('expired')
      emit('close')
      return
    }
    error.value = e instanceof Error ? e.message : 'We could not start your payment. Please try again.'
  }
}
</script>

<template>
  <BaseModal :open="open" :title="disclaimer.title" size="lg" :dismissible="!busy" @close="emit('close')">
    <p v-if="disclaimer.intro" class="text-medium mb-4">{{ disclaimer.intro }}</p>
    <section v-for="section in disclaimer.sections" :key="section.title" class="mb-4">
      <h3 class="payment-disclaimer-heading">{{ section.title }}</h3>
      <!-- eslint-disable-next-line vue/no-v-html -- trusted rich text written by staff in the admin panel -->
      <div class="text-medium" v-html="section.html" />
    </section>
    <p v-if="error" class="bbcc-field-error-text mb-0" role="alert">{{ error }}</p>

    <template #footer>
      <BaseButton variant="light" size="sm" :disabled="busy" @click="emit('close')">Cancel</BaseButton>
      <BaseButton size="sm" :loading="busy" data-testid="agree-and-pay" @click="agreeAndPay">
        {{ busy ? 'Opening payment…' : 'I Agree & Pay' }}
      </BaseButton>
    </template>
  </BaseModal>
</template>

<style scoped>
.payment-disclaimer-heading {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}
</style>
