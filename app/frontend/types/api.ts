// JSON shapes shared by the Rails `/api` controllers and the Vue components. Keep these in step
// with app/controllers/api — a mismatch should fail `npm run typecheck`, not surface in a browser.

/** Body of every non-2xx response rendered by Api::BaseController#render_error. */
export interface ApiErrorBody {
  error: string
  errors?: Record<string, string[]>
  retry_in?: number
  verify?: boolean
  email?: string
}

// --- Payments ---------------------------------------------------------------

export type PayableType = 'booking' | 'golf_reservation' | 'food_order' | 'class_credit_purchase'

/** PaymentWindow#payable_status */
export type PayableStatus = 'unpaid' | 'paid' | 'expired' | 'cancelled' | 'needs_reschedule'

/** GET /api/payment_status/:type/:id */
export interface PaymentStatusResponse {
  status: PayableStatus
  seconds_remaining: number
}

/** POST /api/checkout/:type/:id — Xendit answers with a URL, Midtrans with a Snap token. */
export interface CheckoutResponse {
  checkout_url?: string
  snap_token?: string
}

export interface DisclaimerSection {
  title: string
  /** Rich text from an admin-managed Snippet. */
  html: string
}

export interface Disclaimer {
  title: string
  intro?: string
  sections: DisclaimerSection[]
}

// --- Sign-in, registration and email verification ----------------------------

export interface AuthUrls {
  sessionUrl: string
  registrationUrl: string
  verificationUrl: string
  resendUrl: string
  googleUrl: string
  forgotPasswordUrl: string
}

/** Returned when the account still has to verify its email with a six-digit code. */
export interface VerificationRequired {
  verify: true
  email: string
  retry_in: number
  /** Present when registering restarted the order's payment window. */
  seconds_remaining?: number
}

/** POST /api/session */
export type SessionResponse = { success: true } | VerificationRequired

/** POST /api/registration */
export type RegistrationResponse = VerificationRequired

/** POST /api/verification */
export interface VerificationResponse {
  success: true
}

/** POST /api/verification/resend */
export interface ResendResponse {
  sent: true
  retry_in: number
}
