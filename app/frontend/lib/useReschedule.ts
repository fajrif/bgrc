import { ref } from 'vue'
import { api, ApiError, errorMessage } from './api'
import type { RescheduleResponse } from '~/types/api'

export type RescheduleOutcome = 'moved' | 'taken' | 'failed'

// Sends a late-paid booking's chosen time to PATCH /api/late_reschedules/:type/:id. On success the page
// leaves for wherever the server says (it has set the confirmation notice); `taken` means someone got
// the time first, so the caller should show the calendar as it is now.
export function useReschedule(url: string) {
  const submitting = ref(false)
  const error = ref('')

  async function submit(payload: Record<string, unknown>): Promise<RescheduleOutcome> {
    submitting.value = true
    error.value = ''
    try {
      const moved = await api.patch<RescheduleResponse>(url, payload)
      // Leaving the page: stay busy so the move is not sent twice.
      window.location.assign(moved.redirect_url)
      return 'moved'
    } catch (e) {
      submitting.value = false
      error.value = errorMessage(e, 'We could not move your booking. Please try again.')
      return e instanceof ApiError && e.status === 409 ? 'taken' : 'failed'
    }
  }

  return { submitting, error, submit }
}
