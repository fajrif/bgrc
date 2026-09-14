<script setup lang="ts">
// "Your Order": the basket, where to collect it, and who is collecting. Placing it creates the order
// (and starts its payment window); the server re-prices every line.
import { computed, ref } from 'vue'
import BaseButton from '~/components/ui/BaseButton.vue'
import BaseModal from '~/components/ui/BaseModal.vue'
import { api, ApiError, errorMessage } from '~/lib/api'
import { formatRupiah } from '~/lib/money'
import type { CartLine } from '~/lib/useCart'
import type { FoodOrderCreated, GrabAndGoProps } from '~/types/api'

const props = defineProps<{
  open: boolean
  lines: CartLine[]
  total: number
  items: Record<string, number>
  customer: GrabAndGoProps['customer']
  pickupLocation: string
  paymentWindowMinutes: number
  ordersUrl: string
}>()

const emit = defineEmits<{
  close: []
  placed: [redirectUrl: string]
}>()

const name = ref(props.customer.name)
const phone = ref(props.customer.phone)
const notes = ref('')
const submitting = ref(false)
const error = ref('')
const fieldErrors = ref<Record<string, string[]>>({})

const canPlace = computed(() => props.lines.length > 0 && name.value.trim() !== '' && phone.value.trim() !== '' && !submitting.value)

async function place(): Promise<void> {
  if (!canPlace.value) return
  submitting.value = true
  error.value = ''
  fieldErrors.value = {}
  try {
    const created = await api.post<FoodOrderCreated>(props.ordersUrl, {
      items: props.items,
      customer_name: name.value,
      customer_phone: phone.value,
      notes: notes.value,
    })
    emit('placed', created.redirect_url)
  } catch (e) {
    submitting.value = false
    error.value = errorMessage(e, 'We could not place your order. Please try again.')
    fieldErrors.value = e instanceof ApiError ? (e.body?.errors ?? {}) : {}
  }
}
</script>

<template>
  <BaseModal :open="open" title="Your Order" :dismissible="!submitting" @close="emit('close')">
    <form novalidate @submit.prevent="place">
      <div class="bbcc-modal-summary" data-testid="order-summary">
        <div v-for="line in lines" :key="line.menu.id" class="bbcc-modal-summary-row">
          <span>{{ line.menu.name }} &times; {{ line.quantity }}</span>
          <span>{{ formatRupiah(line.amount) }}</span>
        </div>
      </div>
      <div class="bbcc-modal-summary-row bbcc-modal-summary-total">
        <span>Total</span>
        <span>{{ formatRupiah(total) }}</span>
      </div>

      <div class="bbcc-modal-callout">
        <span class="bbcc-modal-label">Pick up at</span>
        <span class="bbcc-modal-value">{{ pickupLocation }}</span>
      </div>

      <div class="bbcc-field">
        <label for="grab-go-name">Full Name</label>
        <input id="grab-go-name" v-model="name" type="text" autocomplete="name" required>
        <p v-if="fieldErrors.customer_name" class="bbcc-field-error-text">{{ fieldErrors.customer_name[0] }}</p>
      </div>
      <div class="bbcc-field">
        <label for="grab-go-phone">Phone Number</label>
        <input id="grab-go-phone" v-model="phone" type="tel" autocomplete="tel" required>
        <p v-if="fieldErrors.customer_phone" class="bbcc-field-error-text">{{ fieldErrors.customer_phone[0] }}</p>
      </div>
      <div class="bbcc-field">
        <label for="grab-go-notes">Notes (allergies, collection time, anything else)</label>
        <input id="grab-go-notes" v-model="notes" type="text" maxlength="500">
      </div>

      <p class="bbcc-modal-note">
        You have {{ paymentWindowMinutes }} minutes to complete payment once the order is placed.
      </p>
      <p v-if="error" class="bbcc-field-error-text mb-0" role="alert">{{ error }}</p>
      <!-- Lets Enter submit the form; the visible buttons are in the footer. -->
      <button type="submit" hidden></button>
    </form>

    <template #footer>
      <BaseButton variant="light" :disabled="submitting" @click="emit('close')">Keep Browsing</BaseButton>
      <BaseButton :disabled="!canPlace" :loading="submitting" data-testid="place-order" @click="place">
        {{ submitting ? 'Placing…' : 'Place Order' }}
      </BaseButton>
    </template>
  </BaseModal>
</template>
