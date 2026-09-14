import { api } from '~/lib/api'
import type { CheckoutResponse } from '~/types/api'

interface SnapCallbacks {
  onSuccess: () => void
  onPending: () => void
  onError: () => void
  onClose: () => void
}

declare global {
  interface Window {
    /** Midtrans Snap, loaded by the `gateway_checkout_script_tag` helper when Midtrans is active. */
    snap?: { pay: (token: string, callbacks: SnapCallbacks) => void }
  }
}

// Opens the gateway for an order. The result of the payment arrives by webhook, so this only
// navigates: to Xendit's hosted invoice, or into Midtrans Snap rendered on the page.
export async function startCheckout(url: string): Promise<void> {
  const response = await api.post<CheckoutResponse>(url)

  if (response.checkout_url) {
    window.location.assign(response.checkout_url)
    return
  }

  if (response.snap_token && window.snap) {
    const reload = () => window.location.reload()
    window.snap.pay(response.snap_token, { onSuccess: reload, onPending: reload, onError: reload, onClose: reload })
    return
  }

  throw new Error('The payment provider did not return a checkout. Please try again.')
}

// Rails' non-GET links (`method: :delete`) are plain forms carrying the CSRF token, so Vue does the same.
export function submitRailsForm(url: string, method: 'delete' | 'post'): void {
  const form = document.createElement('form')
  form.method = 'post'
  form.action = url

  const fields: Record<string, string> = {}
  if (method !== 'post') fields._method = method
  const param = document.querySelector<HTMLMetaElement>('meta[name="csrf-param"]')?.content
  const token = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content
  if (param && token) fields[param] = token

  for (const [name, value] of Object.entries(fields)) {
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = name
    input.value = value
    form.appendChild(input)
  }

  document.body.appendChild(form)
  form.submit()
}
