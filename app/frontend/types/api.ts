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

// --- Court booking ------------------------------------------------------------

export interface CourtOption {
  id: number
  name: string
  courtTypeId: number | null
}

export interface NamedOption {
  id: number
  name: string
}

export interface AddOnItem {
  id: number
  name: string
  /** Rupiah per hour of the booking. */
  price: number
}

/** Props from CourtBookingHelper#court_booking_props. URLs hold a __COURT__ placeholder. */
export interface CourtBookingProps {
  sport: NamedOption
  courtTypes: NamedOption[]
  courts: CourtOption[]
  initialCourtTypeId: number | null
  initialCourtId: number | null
  initialDate: string
  today: string
  maxDate: string
  items: AddOnItem[]
  urls: { availability: string; quote: string; bookings: string }
  whatsappUrl: string
}

export interface CalendarEvent {
  title: string
  start: string
  end: string
  className: string
  editable: boolean
  extendedProps?: { signUpUrl?: string; classUrl?: string }
}

/** GET /api/courts/:id/availability (CourtAvailability#as_json) */
export interface CourtAvailability {
  court_id: number
  min_duration: number
  slot_min_time: string
  slot_max_time: string
  business_hours: { daysOfWeek: number[]; startTime: string; endTime: string }[]
  events: CalendarEvent[]
}

export interface QuoteLine {
  label: string
  amount: number
  amount_label: string
}

/** POST /api/courts/:id/quote (CourtBookingRequest#as_json). Price fields are absent until a slot is valid. */
export interface CourtQuote {
  bookable: boolean
  message: string | null
  court?: string
  date_label?: string
  duration_label?: string
  court_fee_label?: string
  lines?: QuoteLine[]
  total?: number
  total_label?: string
  event_title?: string
}

/** POST /api/courts/:id/bookings */
export interface CourtBookingCreated {
  order_id: string
  redirect_url: string
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
