import type { Component } from 'vue'

// Every component a Rails view can mount by name via `vue_component`. Lazy imports keep each
// page's download to the components it actually renders.
export const registry: Record<string, () => Promise<{ default: Component }>> = {
  CourtBookingApp: () => import('./booking/CourtBookingApp.vue'),
  PaymentPanel: () => import('./payment/PaymentPanel.vue'),
}
