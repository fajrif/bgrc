<script setup lang="ts">
// "Confirm Purchase": what is about to be bought. Confirming creates the unpaid purchase and opens its
// page, where the payment window runs and payment is taken.
import BaseButton from '~/components/ui/BaseButton.vue'
import BaseModal from '~/components/ui/BaseModal.vue'

defineProps<{
  open: boolean
  busy: boolean
  className: string
  /** Only for a prescheduled class. */
  sessionLabel: string | null
  packLabel: string
  paxLabel: string
  totalLabel: string
  /** Only for credits used later. */
  validity: string | null
  paymentWindowMinutes: number
}>()

const emit = defineEmits<{
  close: []
  confirm: []
}>()
</script>

<template>
  <BaseModal :open="open" title="Confirm Purchase" :dismissible="!busy" @close="emit('close')">
    <table class="table table-borderless mb-2" data-testid="class-confirm-summary">
      <tbody>
        <tr>
          <td class="text-muted ps-0">Class</td>
          <td class="fw-semibold">{{ className }}</td>
        </tr>
        <tr v-if="sessionLabel">
          <td class="text-muted ps-0">Session Date</td>
          <td>{{ sessionLabel }}</td>
        </tr>
        <tr>
          <td class="text-muted ps-0">Pack Size</td>
          <td>{{ packLabel }}</td>
        </tr>
        <tr>
          <td class="text-muted ps-0">Pax</td>
          <td>{{ paxLabel }}</td>
        </tr>
        <tr>
          <td class="text-muted ps-0">Total Price</td>
          <td class="fw-semibold">{{ totalLabel }}</td>
        </tr>
        <tr v-if="validity">
          <td class="text-muted ps-0">Credits Valid</td>
          <td class="text-muted small">{{ validity }} from payment date</td>
        </tr>
      </tbody>
    </table>
    <p class="bbcc-modal-note mb-0">You will have {{ paymentWindowMinutes }} minutes to complete payment.</p>

    <template #footer>
      <BaseButton variant="light" size="sm" :disabled="busy" @click="emit('close')">Cancel</BaseButton>
      <BaseButton size="sm" :loading="busy" data-testid="confirm-class-purchase" @click="emit('confirm')">
        {{ busy ? 'Registering…' : 'Confirm & Pay' }}
      </BaseButton>
    </template>
  </BaseModal>
</template>
