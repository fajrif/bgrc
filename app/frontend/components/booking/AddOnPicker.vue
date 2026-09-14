<script setup lang="ts">
// Add-ons chosen before booking, below "Your Booking Details". Each is priced per hour of the
// booking; the quote beside it shows the total for the chosen slot.
import QtyStepper from '~/components/ui/QtyStepper.vue'
import { formatRupiah } from '~/lib/money'
import type { AddOnItem } from '~/types/api'

defineProps<{
  items: AddOnItem[]
}>()

/** { item_id: quantity } — only chosen items are present. */
const chosen = defineModel<Record<string, number>>({ required: true })

function quantityOf(id: number): number {
  return chosen.value[String(id)] ?? 0
}

function toggle(id: number, checked: boolean): void {
  const next = { ...chosen.value }
  if (checked) next[String(id)] = 1
  else delete next[String(id)]
  chosen.value = next
}

function setQuantity(id: number, quantity: number): void {
  chosen.value = { ...chosen.value, [String(id)]: quantity }
}
</script>

<template>
  <fieldset class="booking-addons">
    <legend class="booking-addons-title">Add-ons</legend>
    <ul class="booking-addons-list">
      <li v-for="item in items" :key="item.id" class="booking-addons-item">
        <label class="booking-addons-label">
          <input
            type="checkbox"
            :checked="quantityOf(item.id) > 0"
            @change="toggle(item.id, ($event.target as HTMLInputElement).checked)"
          >
          <span>{{ item.name }}</span>
          <span class="booking-addons-price">{{ formatRupiah(item.price) }} / hour</span>
        </label>
        <QtyStepper
          v-if="quantityOf(item.id) > 0"
          :label="item.name"
          :model-value="quantityOf(item.id)"
          @update:model-value="setQuantity(item.id, $event)"
        />
      </li>
    </ul>
  </fieldset>
</template>

<style scoped>
.booking-addons {
  margin: 0 0 28px;
  padding: 0;
  border: 0;
}

.booking-addons-title {
  float: none;
  width: auto;
  margin-bottom: 12px;
  font-size: 15px;
  font-weight: 600;
}

.booking-addons-list {
  margin: 0;
  padding: 0;
  list-style: none;
}

.booking-addons-item {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 0;
  border-top: 1px solid var(--bbcc-line, #ddd);
}

.booking-addons-label {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px 10px;
  margin: 0;
  font-size: 15px;
  cursor: pointer;
}

/* The site's theme sizes form inputs as full-width blocks; a checkbox here sits inline with its label. */
.booking-addons-label input[type='checkbox'] {
  display: inline-block;
  flex: 0 0 auto;
  width: 16px;
  height: 16px;
  margin: 0;
  padding: 0;
}

.booking-addons-price {
  color: var(--bbcc-ink-soft, #777);
  font-size: 13px;
}
</style>
