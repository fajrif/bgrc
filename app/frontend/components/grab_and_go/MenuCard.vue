<script setup lang="ts">
// One dish on the Grab & Go menu, with its quantity stepper. Sold-out dishes stay on the menu, greyed.
import { formatRupiah } from '~/lib/money'
import type { MenuOption } from '~/types/api'

defineProps<{
  menu: MenuOption
  quantity: number
  /** Most that can be ordered: the stock left, or the online ceiling. */
  limit: number
}>()

const emit = defineEmits<{
  change: [quantity: number]
}>()
</script>

<template>
  <article
    class="bbcc-menu-card"
    :class="{ 'bbcc-menu-card-out': !menu.available, 'bbcc-menu-card-picked': quantity > 0 }"
    :data-testid="`menu-${menu.id}`"
  >
    <span class="bbcc-menu-card-thumb">
      <img v-if="menu.imageUrl" :src="menu.imageUrl" :alt="menu.name" loading="lazy">
    </span>
    <div class="bbcc-menu-card-body">
      <span class="bbcc-menu-card-cat">{{ menu.categoryName }}</span>
      <h3 class="bbcc-menu-card-name">{{ menu.name }}</h3>
      <p class="bbcc-menu-card-price">
        {{ formatRupiah(menu.price) }}
        <s v-if="menu.originalPrice" class="bbcc-menu-card-was">{{ formatRupiah(menu.originalPrice) }}</s>
      </p>
      <div v-if="menu.available" class="bbcc-qty">
        <button
          type="button"
          class="bbcc-qty-btn bbcc-qty-minus"
          :aria-label="`Remove one ${menu.name}`"
          :disabled="quantity === 0"
          @click="emit('change', quantity - 1)"
        >&minus;</button>
        <output class="bbcc-qty-value" aria-live="polite">{{ quantity }}</output>
        <button
          type="button"
          class="bbcc-qty-btn bbcc-qty-plus"
          :aria-label="`Add one ${menu.name}`"
          :disabled="quantity >= limit"
          @click="emit('change', quantity + 1)"
        >+</button>
      </div>
      <span v-else class="bbcc-badge bbcc-badge-muted">Sold out</span>
    </div>
  </article>
</template>
