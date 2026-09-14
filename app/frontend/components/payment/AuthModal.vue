<script setup lang="ts">
// Sign in or create an account without leaving the payment page. New and unverified accounts confirm
// their email with a six-digit code typed right here, so the order and its countdown stay on screen.
import { computed, onBeforeUnmount, ref } from 'vue'
import BaseButton from '~/components/ui/BaseButton.vue'
import BaseModal from '~/components/ui/BaseModal.vue'
import { api, ApiError } from '~/lib/api'
import { submitRailsForm } from '~/lib/checkout'
import type {
  AuthUrls,
  PayableType,
  RegistrationResponse,
  ResendResponse,
  SessionResponse,
  VerificationRequired,
  VerificationResponse,
} from '~/types/api'

const props = defineProps<{
  open: boolean
  auth: AuthUrls
  type: PayableType
  orderId: string
}>()

const emit = defineEmits<{
  close: []
  /** Signed in (or verified): the page reloads so the order joins the account and Pay opens. */
  authenticated: []
  /** Registering restarted the order's payment window. */
  windowReset: [seconds: number]
}>()

type Pane = 'signin' | 'register' | 'verify'

const pane = ref<Pane>('signin')
const email = ref('')
const password = ref('')
const fullName = ref('')
const phone = ref('')
const code = ref('')
const busy = ref(false)
const error = ref('')
const fieldErrors = ref<Record<string, string[]>>({})
const notice = ref('')
const retryIn = ref(0)
let retryTimer: number | undefined

const title = computed(() => {
  if (pane.value === 'verify') return 'Verify your email'
  return pane.value === 'register' ? 'Create an account to pay' : 'Sign in to pay'
})

function show(next: Pane): void {
  pane.value = next
  error.value = ''
  fieldErrors.value = {}
  notice.value = ''
}

function startRetryCountdown(seconds: number): void {
  window.clearInterval(retryTimer)
  retryIn.value = seconds
  retryTimer = window.setInterval(() => {
    retryIn.value = Math.max(0, retryIn.value - 1)
    if (retryIn.value === 0) window.clearInterval(retryTimer)
  }, 1000)
}

onBeforeUnmount(() => window.clearInterval(retryTimer))

function awaitCode(response: VerificationRequired): void {
  email.value = response.email
  show('verify')
  code.value = ''
  notice.value = `We sent a 6-digit code to ${response.email}.`
  startRetryCountdown(response.retry_in)
}

async function run(action: () => Promise<void>): Promise<void> {
  busy.value = true
  error.value = ''
  fieldErrors.value = {}
  try {
    await action()
  } catch (e) {
    if (e instanceof ApiError) {
      error.value = e.message
      fieldErrors.value = e.body?.errors ?? {}
      if (e.body?.retry_in) startRetryCountdown(e.body.retry_in)
      // The account exists, but the code email failed: let them ask for another from the verify pane.
      if (e.body?.verify && e.body.email) {
        email.value = e.body.email
        pane.value = 'verify'
      }
    } else {
      error.value = 'Something went wrong. Please try again.'
    }
  } finally {
    busy.value = false
  }
}

const signIn = () =>
  run(async () => {
    const response = await api.post<SessionResponse>(props.auth.sessionUrl, {
      email: email.value,
      password: password.value,
    })
    if ('verify' in response) awaitCode(response)
    else emit('authenticated')
  })

const register = () =>
  run(async () => {
    const response = await api.post<RegistrationResponse>(props.auth.registrationUrl, {
      full_name: fullName.value,
      email: email.value,
      phone: phone.value,
      password: password.value,
      type: props.type,
      order_id: props.orderId,
    })
    if (response.seconds_remaining !== undefined) emit('windowReset', response.seconds_remaining)
    awaitCode(response)
  })

const verify = () =>
  run(async () => {
    await api.post<VerificationResponse>(props.auth.verificationUrl, { email: email.value, code: code.value })
    emit('authenticated')
  })

const resend = () =>
  run(async () => {
    const response = await api.post<ResendResponse>(props.auth.resendUrl, { email: email.value })
    code.value = ''
    notice.value = `A new code is on its way to ${email.value}.`
    startRetryCountdown(response.retry_in)
  })

function continueWithGoogle(): void {
  submitRailsForm(props.auth.googleUrl, 'post')
}

function firstError(field: string): string | undefined {
  return fieldErrors.value[field]?.[0]
}
</script>

<template>
  <BaseModal :open="open" :title="title" :dismissible="!busy" @close="emit('close')">
    <div v-if="pane !== 'verify'" class="auth-tabs" role="tablist">
      <button type="button" role="tab" class="auth-tab" :aria-selected="pane === 'signin'" @click="show('signin')">
        Sign in
      </button>
      <button type="button" role="tab" class="auth-tab" :aria-selected="pane === 'register'" @click="show('register')">
        Create account
      </button>
    </div>

    <p v-if="notice" class="text-medium mb-3" role="status">{{ notice }}</p>
    <p v-if="error" class="bbcc-field-error-text mb-3" role="alert">{{ error }}</p>

    <form v-if="pane === 'signin'" novalidate @submit.prevent="signIn">
      <div class="bbcc-field">
        <label for="auth-signin-email">Email Address</label>
        <input id="auth-signin-email" v-model.trim="email" type="email" autocomplete="email" required>
      </div>
      <div class="bbcc-field">
        <label for="auth-signin-password">Password</label>
        <input id="auth-signin-password" v-model="password" type="password" autocomplete="current-password" required>
      </div>
      <BaseButton type="submit" block :loading="busy">Sign In</BaseButton>
      <p class="auth-aside"><a :href="auth.forgotPasswordUrl">Forgot your password?</a></p>
    </form>

    <form v-else-if="pane === 'register'" novalidate @submit.prevent="register">
      <div class="bbcc-field">
        <label for="auth-register-name">Full Name</label>
        <input id="auth-register-name" v-model.trim="fullName" type="text" autocomplete="name" required>
        <p v-if="firstError('full_name')" class="bbcc-field-error-text">{{ firstError('full_name') }}</p>
      </div>
      <div class="bbcc-field">
        <label for="auth-register-email">Email Address</label>
        <input id="auth-register-email" v-model.trim="email" type="email" autocomplete="email" required>
        <p v-if="firstError('email')" class="bbcc-field-error-text">{{ firstError('email') }}</p>
      </div>
      <div class="bbcc-field">
        <label for="auth-register-phone">Phone Number</label>
        <input id="auth-register-phone" v-model.trim="phone" type="tel" autocomplete="tel" required>
        <p v-if="firstError('phone')" class="bbcc-field-error-text">{{ firstError('phone') }}</p>
      </div>
      <div class="bbcc-field">
        <label for="auth-register-password">Password</label>
        <input id="auth-register-password" v-model="password" type="password" autocomplete="new-password" required>
        <p v-if="firstError('password')" class="bbcc-field-error-text">{{ firstError('password') }}</p>
      </div>
      <BaseButton type="submit" block :loading="busy">Create Account</BaseButton>
      <p class="auth-aside">You can add the rest of your profile later from your account page.</p>
    </form>

    <form v-else novalidate @submit.prevent="verify">
      <div class="bbcc-field">
        <label for="auth-verify-code">6-digit code</label>
        <input
          id="auth-verify-code"
          v-model.trim="code"
          class="auth-code-input"
          type="text"
          inputmode="numeric"
          autocomplete="one-time-code"
          pattern="[0-9]*"
          maxlength="6"
          required
        >
      </div>
      <BaseButton type="submit" block :loading="busy" :disabled="code.length !== 6">Verify & Continue</BaseButton>
      <p class="auth-aside">
        Didn't get it?
        <button type="button" class="auth-link" :disabled="busy || retryIn > 0" @click="resend">
          {{ retryIn > 0 ? `Send a new code in ${retryIn}s` : 'Send a new code' }}
        </button>
      </p>
    </form>

    <template v-if="pane !== 'verify'">
      <div class="auth-divider"><span>or</span></div>
      <BaseButton variant="light" block :disabled="busy" @click="continueWithGoogle">
        <i class="fa-brands fa-google" aria-hidden="true"></i> Continue with Google
      </BaseButton>
    </template>
  </BaseModal>
</template>

<style scoped>
.auth-tabs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  margin-bottom: 1.25rem;
  border-bottom: 1px solid var(--bbcc-line, #ddd);
}

.auth-tab {
  padding: 0.6rem 0;
  border: 0;
  border-bottom: 2px solid transparent;
  background: none;
  font-weight: 600;
  color: inherit;
  opacity: 0.55;
}

.auth-tab[aria-selected='true'] {
  border-bottom-color: currentColor;
  opacity: 1;
}

.auth-aside {
  margin: 0.75rem 0 0;
  font-size: 0.875rem;
  text-align: center;
}

.auth-link {
  padding: 0;
  border: 0;
  background: none;
  color: inherit;
  text-decoration: underline;
}

.auth-link:disabled {
  opacity: 0.55;
  text-decoration: none;
}

.auth-code-input {
  font-family: Menlo, Consolas, monospace;
  font-size: 1.5rem;
  letter-spacing: 0.5em;
  text-align: center;
}

.auth-divider {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 1.25rem 0;
  font-size: 0.875rem;
  opacity: 0.6;
}

.auth-divider::before,
.auth-divider::after {
  content: '';
  flex: 1;
  border-top: 1px solid var(--bbcc-line, #ddd);
}
</style>
