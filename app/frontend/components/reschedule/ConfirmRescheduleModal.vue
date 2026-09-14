<script setup lang="ts">
// The last look before a late-paid booking moves to its new time and is confirmed.
import BaseButton from '~/components/ui/BaseButton.vue'
import BaseModal from '~/components/ui/BaseModal.vue'

defineProps<{
  open: boolean
  busy: boolean
  rows: { label: string; value: string }[]
}>()

const emit = defineEmits<{
  close: []
  confirm: []
}>()
</script>

<template>
  <BaseModal :open="open" title="Confirm New Time" :dismissible="!busy" @close="emit('close')">
    <div class="bbcc-modal-group" data-testid="reschedule-summary">
      <div v-for="row in rows" :key="row.label" class="bbcc-modal-summary-row">
        <span>{{ row.label }}</span>
        <span>{{ row.value }}</span>
      </div>
    </div>
    <p class="bbcc-modal-note mb-0">
      Your booking moves to this time and is confirmed straight away. There is nothing more to pay.
    </p>

    <template #footer>
      <BaseButton variant="light" size="sm" :disabled="busy" @click="emit('close')">Cancel</BaseButton>
      <BaseButton size="sm" :loading="busy" data-testid="confirm-reschedule" @click="emit('confirm')">
        {{ busy ? 'Confirming…' : 'Confirm New Time' }}
      </BaseButton>
    </template>
  </BaseModal>
</template>
