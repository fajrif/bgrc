import { computed, ref, watch } from 'vue'
import type { MenuOption } from '~/types/api'

// The Grab & Go basket. It lives in sessionStorage so a refresh, or a detour to sign in, doesn't lose it,
// but nothing reaches the server — and no payment clock starts — until the order is placed.

const STORAGE_KEY = 'bbcc.grabAndGo.cart'

export interface CartLine {
  menu: MenuOption
  quantity: number
  amount: number
}

function readStored(): Record<string, unknown> {
  try {
    const parsed: unknown = JSON.parse(window.sessionStorage.getItem(STORAGE_KEY) ?? '{}')
    return parsed !== null && typeof parsed === 'object' ? (parsed as Record<string, unknown>) : {}
  } catch {
    return {}
  }
}

function writeStored(quantities: Record<string, number>): void {
  try {
    if (Object.keys(quantities).length === 0) window.sessionStorage.removeItem(STORAGE_KEY)
    else window.sessionStorage.setItem(STORAGE_KEY, JSON.stringify(quantities))
  } catch {
    // Storage can be unavailable (private mode, quota); the basket still works for this page view.
  }
}

export function useCart(menus: MenuOption[], maxQuantity: number) {
  const menusById = new Map(menus.map((menu) => [menu.id, menu]))

  function limitFor(menu: MenuOption): number {
    return Math.min(maxQuantity, menu.stock ?? maxQuantity)
  }

  // A saved basket may be older than the menu: drop what is gone or sold out, and cap what is left.
  const restored: Record<string, number> = {}
  for (const [id, stored] of Object.entries(readStored())) {
    const menu = menusById.get(Number(id))
    const quantity = Math.floor(Number(stored))
    if (menu?.available && quantity > 0) restored[id] = Math.min(quantity, limitFor(menu))
  }

  const quantities = ref<Record<string, number>>(restored)
  watch(quantities, writeStored, { deep: true, immediate: true })

  function quantityOf(id: number): number {
    return quantities.value[String(id)] ?? 0
  }

  function setQuantity(menu: MenuOption, quantity: number): void {
    const next = { ...quantities.value }
    const clamped = Math.max(0, Math.min(Math.floor(quantity), limitFor(menu)))
    if (clamped === 0) delete next[String(menu.id)]
    else next[String(menu.id)] = clamped
    quantities.value = next
  }

  function clear(): void {
    quantities.value = {}
  }

  const lines = computed<CartLine[]>(() =>
    Object.entries(quantities.value).flatMap(([id, quantity]) => {
      const menu = menusById.get(Number(id))
      return menu ? [{ menu, quantity, amount: menu.price * quantity }] : []
    }),
  )
  const count = computed(() => lines.value.reduce((sum, line) => sum + line.quantity, 0))
  const total = computed(() => lines.value.reduce((sum, line) => sum + line.amount, 0))

  return { quantities, quantityOf, setQuantity, limitFor, clear, lines, count, total }
}
