<script setup lang="ts">
// The rules a customer accepts before spending a class credit on a session.
import BaseButton from '~/components/ui/BaseButton.vue'
import BaseModal from '~/components/ui/BaseModal.vue'

defineProps<{
  open: boolean
  busy: boolean
}>()

const emit = defineEmits<{
  close: []
  agree: []
}>()
</script>

<template>
  <BaseModal :open="open" title="Confirm Session Claim" size="lg" :dismissible="!busy" @close="emit('close')">
    <p class="text-medium mb-3">
      Please review the details before claiming this session. By proceeding, you agree to the following:
    </p>

    <h3 class="claim-disclaimer-heading">Rescheduling Policy</h3>
    <ul class="text-medium small mb-3">
      <li>You may reschedule (cancel and return the credit) within <strong>24 hours after this claim</strong>.</li>
      <li>After the 24-hour window has passed, the session is <strong>locked</strong> and cannot be cancelled or rescheduled.</li>
      <li>If you do not attend the session, your credit will be forfeited.</li>
    </ul>

    <h3 class="claim-disclaimer-heading">Court &amp; Coach</h3>
    <ul class="text-medium small mb-3">
      <li>Your selected court and coach will be reserved exclusively for your session.</li>
      <li>Please arrive 10 minutes before the scheduled start time.</li>
    </ul>

    <p class="text-muted small mb-0">
      By clicking "I Agree &amp; Claim", you confirm that you have read and accept the rescheduling rules above.
    </p>

    <template #footer>
      <BaseButton variant="light" size="sm" :disabled="busy" @click="emit('close')">Cancel</BaseButton>
      <BaseButton size="sm" :loading="busy" data-testid="agree-and-claim" @click="emit('agree')">
        {{ busy ? 'Claiming…' : 'I Agree & Claim' }}
      </BaseButton>
    </template>
  </BaseModal>
</template>

<style scoped>
.claim-disclaimer-heading {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}
</style>
