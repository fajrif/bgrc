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

// --- Golf -----------------------------------------------------------------------

export interface GolfItemOption {
  id: number
  name: string
  price: number
  /** Charged per player; otherwise once per booking. */
  perPerson: boolean
}

/** Props from GolfBookingHelper#golf_booking_props. */
export interface GolfBookingProps {
  course: { id: number; name: string; holesList: number[]; maxPlayers: number }
  today: string
  maxDate: string
  items: GolfItemOption[]
  urls: { teeTimes: string; quote: string; reservations: string }
}

/** GET /book/golf/tee_times?date= (GolfController#tee_times) */
export interface TeeTimeSlot {
  /** "HH:MM" */
  time: string
  available: boolean
  past: boolean
  remaining: number
}

/** POST /api/golf/quote (GolfReservationRequest#as_json). Price fields are absent until a tee time is chosen. */
export interface GolfQuote {
  bookable: boolean
  message: string | null
  tee_time_label?: string
  holes_label?: string
  players_label?: string
  remaining?: number
  rate_label?: string
  green_fee_label?: string
  lines?: QuoteLine[]
  total?: number
  total_label?: string
}

/** POST /api/golf/reservations */
export interface GolfReservationCreated {
  order_id: string
  redirect_url: string
}

// --- Grab & Go -------------------------------------------------------------------

export interface MenuOption {
  id: number
  name: string
  categoryName: string | null
  categorySlug: string | null
  /** What the dish costs today (the discounted price when there is one). */
  price: number
  /** The undiscounted price, only when a discount applies. */
  originalPrice: number | null
  available: boolean
  /** Portions left, or null when the dish isn't stock-counted. */
  stock: number | null
  imageUrl: string | null
}

/** Props from GrabAndGoHelper#grab_and_go_props. */
export interface GrabAndGoProps {
  menus: MenuOption[]
  categories: { slug: string; name: string }[]
  customer: { name: string; phone: string }
  pickupLocation: string
  paymentWindowMinutes: number
  maxQuantity: number
  ordersUrl: string
}

/** POST /api/grab_and_go/orders */
export interface FoodOrderCreated {
  order_id: string
  redirect_url: string
}

// --- Group classes & class credits -------------------------------------------------

export interface ClassPackOption {
  sessions: number
  label: string
  /** How long the credits last once paid, e.g. "2 months". */
  validity: string
}

/** One upcoming session of a prescheduled class (ClassCreditPurchaseRequest.sessions_for). */
export interface ClassSessionOption {
  /** Wall-clock "YYYY-MM-DD HH:MM", sent back when buying. */
  start: string
  dateLabel: string
  startTime: string
  endTime: string
  placesLeft: number
}

/** Props from GroupClassBookingHelper#class_purchase_props. */
export interface ClassPurchaseProps {
  groupClass: { id: number; name: string; prescheduled: boolean; minPax: number; maxPax: number }
  packs: ClassPackOption[]
  /** Rupiah keyed "sessions-pax". */
  prices: Record<string, number>
  sessions: ClassSessionOption[]
  paymentWindowMinutes: number
  urls: { purchases: string; sessions: string }
}

/** GET /api/group_classes/:id/sessions */
export interface ClassSessionsResponse {
  sessions: ClassSessionOption[]
}

/** POST /api/class_credit_purchases */
export interface ClassCreditPurchaseCreated {
  order_id: string
  redirect_url: string
}

/** Props from GroupClassBookingHelper#class_session_claim_props. URLs hold a __COURT__ placeholder. */
export interface ClassSessionClaimProps {
  groupClass: { name: string; durationHours: number; durationLabel: string }
  pax: number
  courtTypes: NamedOption[]
  courts: CourtOption[]
  coaches: NamedOption[]
  initialCourtTypeId: number | null
  initialCourtId: number | null
  today: string
  maxDate: string
  urls: { availability: string; claim: string }
}

/** POST /api/class_credits/:id/claims */
export interface ClassSessionClaimed {
  redirect_url: string
}

// --- Late-payment reschedule ----------------------------------------------------

/** Props for CourtRescheduleApp (LateRescheduleHelper#late_reschedule_app). URLs hold a __COURT__ placeholder. */
export interface CourtRescheduleProps {
  courts: NamedOption[]
  initialCourtId: number | null
  durationHours: number
  durationLabel: string
  today: string
  maxDate: string
  urls: { availability: string; reschedule: string }
}

/** Props for TeeTimeRescheduleApp. */
export interface TeeTimeRescheduleProps {
  courseName: string
  players: number
  holesLabel: string
  today: string
  maxDate: string
  urls: { teeTimes: string; reschedule: string }
}

/** Props for ClassRescheduleApp. */
export interface ClassRescheduleProps {
  className: string
  pax: number
  sessions: ClassSessionOption[]
  urls: { sessions: string; reschedule: string }
}

/** PATCH /api/late_reschedules/:type/:id */
export interface RescheduleResponse {
  redirect_url: string
}

// --- My Bookings calendar -----------------------------------------------------------

/** Props for ScheduleCalendarApp (users/bookings/calendar). */
export interface ScheduleCalendarProps {
  eventsUrl: string
  today: string
}

/** extendedProps of each event in GET /account/bookings/calendar.json (Users::BookingsController#calendar). */
export interface ScheduleEventDetails {
  type: string
  /** Absent for class sessions, which are addressed through their credit purchase. */
  orderId: string | null
  dateLabel: string
  subtitleLabel: string
  subtitle: string | null
  statusLabel: string
  paxLabel: string
  pax: number | null
  holesLabel?: string
  priceLabel: string | null
  detailUrl: string | null
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
