import type { Component } from 'vue'

// Every component a Rails view can mount by name via `vue_component`. Lazy imports keep each
// page's download to the components it actually renders.
export const registry: Record<string, () => Promise<{ default: Component }>> = {
  ClassPurchaseApp: () => import('./classes/ClassPurchaseApp.vue'),
  ClassSessionClaimApp: () => import('./classes/ClassSessionClaimApp.vue'),
  CourtBookingApp: () => import('./booking/CourtBookingApp.vue'),
  GolfBookingApp: () => import('./golf/GolfBookingApp.vue'),
  GrabAndGoApp: () => import('./grab_and_go/GrabAndGoApp.vue'),
  PaymentPanel: () => import('./payment/PaymentPanel.vue'),
}
