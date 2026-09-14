<script setup lang="ts">
// Same markup and classes as the ERB add-on stepper (quantity_input.css), so it looks identical.
// The page has to load that stylesheet: `stylesheet_link_tag "quantity_input"`.
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    label: string
    min?: number
    max?: number
    disabled?: boolean
  }>(),
  { min: 1, max: 6, disabled: false },
)

const quantity = defineModel<number>({ required: true })

const canDecrease = computed(() => !props.disabled && quantity.value > props.min)
const canIncrease = computed(() => !props.disabled && quantity.value < props.max)
</script>

<template>
  <div class="qty-input" role="group" :aria-label="`${label} quantity`">
    <button
      type="button"
      class="qty-count qty-count--minus"
      :disabled="!canDecrease"
      :aria-label="`Decrease ${label}`"
      @click="quantity--"
    >-</button>
    <input class="product-qty" type="number" :min="min" :max="max" :value="quantity" readonly :aria-label="`${label} quantity`">
    <button
      type="button"
      class="qty-count qty-count--add"
      :disabled="!canIncrease"
      :aria-label="`Increase ${label}`"
      @click="quantity++"
    >+</button>
  </div>
</template>
