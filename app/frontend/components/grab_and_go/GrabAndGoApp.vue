<script setup lang="ts">
// The Grab & Go menu (restaurants#show for the grab-and-go venue): browse by category, build a basket,
// and place the order for pickup. The basket survives a refresh; the order page handles payment.
import { computed, ref } from 'vue'
import GrabAndGoCheckout from './GrabAndGoCheckout.vue'
import MenuCard from './MenuCard.vue'
import { formatRupiah } from '~/lib/money'
import { useCart } from '~/lib/useCart'
import type { GrabAndGoProps } from '~/types/api'

const props = defineProps<GrabAndGoProps>()

const { quantities, quantityOf, setQuantity, limitFor, clear, lines, count, total } = useCart(props.menus, props.maxQuantity)

const filter = ref('all')
const checkoutOpen = ref(false)

// Filtering in place keeps both the scroll position and the basket.
const visibleMenus = computed(() =>
  filter.value === 'all' ? props.menus : props.menus.filter((menu) => menu.categorySlug === filter.value),
)

function onPlaced(redirectUrl: string): void {
  clear()
  window.location.assign(redirectUrl)
}
</script>

<template>
  <nav v-if="categories.length > 1" class="bbcc-tabs bbcc-tabs-center bbcc-menu-tabs" aria-label="Menu categories">
    <button type="button" class="bbcc-tab" :class="{ active: filter === 'all' }" @click="filter = 'all'">All</button>
    <button
      v-for="category in categories"
      :key="category.slug"
      type="button"
      class="bbcc-tab"
      :class="{ active: filter === category.slug }"
      @click="filter = category.slug"
    >
      {{ category.name }}
    </button>
  </nav>

  <div class="row g-4 bbcc-menu-grid">
    <div v-for="menu in visibleMenus" :key="menu.id" class="col-12 col-md-6 col-lg-4 bbcc-menu-col">
      <MenuCard
        :menu="menu"
        :quantity="quantityOf(menu.id)"
        :limit="limitFor(menu)"
        @change="setQuantity(menu, $event)"
      />
    </div>
  </div>

  <!-- Sticky summary bar, shown once something is in the basket. -->
  <div class="bbcc-cart-bar" :hidden="count === 0" data-testid="cart-bar">
    <div class="container-lg bbcc-cart-bar-inner">
      <div class="bbcc-cart-bar-summary">
        <span class="bbcc-cart-bar-count">{{ count }} {{ count === 1 ? 'item' : 'items' }}</span>
        <span class="bbcc-cart-bar-total">{{ formatRupiah(total) }}</span>
      </div>
      <div class="bbcc-cart-bar-actions">
        <button type="button" class="bbcc-btn bbcc-btn-light bbcc-btn-sm" @click="clear">Clear</button>
        <button type="button" class="bbcc-btn bbcc-btn-sm" data-testid="open-checkout" @click="checkoutOpen = true">Place Order</button>
      </div>
    </div>
  </div>

  <GrabAndGoCheckout
    :open="checkoutOpen"
    :lines="lines"
    :total="total"
    :items="quantities"
    :customer="customer"
    :pickup-location="pickupLocation"
    :payment-window-minutes="paymentWindowMinutes"
    :orders-url="ordersUrl"
    @close="checkoutOpen = false"
    @placed="onPlaced"
  />
</template>
