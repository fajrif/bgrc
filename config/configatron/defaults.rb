# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
#
#   configatron.file.storage = :s3
configatron.site_name = "balibeachcountryclub.com"
configatron.site_title = "Bali Beach Country Club"
configatron.site_description = "Welcome to the Bali Beach Country Club, where tropical paradise meets world-class sporting facilities."
# Social Media
configatron.social_facebook_url = "https://www.facebook.com/"
configatron.social_twitter_url = "https://twitter.com/"
configatron.social_instagram_url = "https://instagram.com/"
configatron.social_linkedin_url = "https://linkedin.com/"
configatron.social_google_plus_url = "https://plus.google.com/"

configatron.location_address = "Jl. Pantai Mengiat No. 88<br/> Kawasan Wisata ITDC Nusa Dua Lot S-5 Benoa,<br/> Kuta Selatan, Badung, Bali<br/> 80363"
configatron.company_phone1 = "(0361) 771 791"
configatron.company_phone2 = "(+62) 811 3831 4769"
configatron.whatsapp_number = "628113831 4769"
configatron.credit_validity_months = 2
configatron.max_reschedule_count = 2
configatron.admin_email = "info@balibeachcountryclub.com"
configatron.no_reply_email = "no-reply@balibeachcountryclub.com"
configatron.info_email = "info@balibeachcountryclub.com"
configatron.recaptcha_v3_site_key = ENV['RECAPTCHA_V3_SITE_KEY']
configatron.recaptcha_v3_secret_key = ENV['RECAPTCHA_V3_SECRET_KEY']
configatron.recaptcha_v2_site_key = ENV['RECAPTCHA_V2_SITE_KEY']
configatron.recaptcha_v2_secret_key = ENV['RECAPTCHA_V2_SECRET_KEY']

# --- Payment gateway -------------------------------------------------------
# Which gateway new checkouts go through. Existing purchases always resolve
# through their own `payment_gateway` column, so flipping this never changes how
# a historical row is read — only where the next payment is sent.
#
# Defaults to midtrans so that deploying this code changes nothing on its own;
# switching to Xendit is a deliberate opt-in via the env var. See
# docs/xendit-setup.md.
configatron.payment_gateway = ENV.fetch("PAYMENT_GATEWAY", "midtrans")

# Xendit. Note there is no separate sandbox hostname — Test Mode vs Live Mode is
# decided entirely by the key prefix (xnd_development_… vs xnd_production_…).
configatron.xendit_api_url        = ENV.fetch("XENDIT_API_URL", "https://api.xendit.co")
configatron.xendit_secret_key     = ENV["XENDIT_SECRET_KEY"]
configatron.xendit_callback_token = ENV["XENDIT_CALLBACK_TOKEN"]

# Midtrans (legacy). URLs default to sandbox; set MIDTRANS_API_URL and
# MIDTRANS_JS_FILE to the app.midtrans.com equivalents for real transactions.
configatron.midtrans_api_url =
	ENV.fetch("MIDTRANS_API_URL", "https://app.sandbox.midtrans.com/snap/v1/transactions")
configatron.midtrans_js_file =
	ENV.fetch("MIDTRANS_JS_FILE", "https://app.sandbox.midtrans.com/snap/snap.js")
configatron.midtrans_status_api_url =
	ENV.fetch("MIDTRANS_STATUS_API_URL", "https://api.sandbox.midtrans.com/v2")
configatron.midtrans_merchant_id = ENV["MIDTRANS_MERCHANT_ID"]
configatron.midtrans_client_key  = ENV["MIDTRANS_CLIENT_KEY"]
configatron.midtrans_server_key  = ENV["MIDTRANS_SERVER_KEY"]

# How long a checkout stays payable. The three timed products carry their own
# expires_at (set from the DB clock at creation); this is the fallback for
# products that don't, and the cap handed to the gateway.
configatron.payment_window_minutes = 10
configatron.class_credit_payment_window_hours = 24

# Outbound HTTP timeouts for gateway calls, in seconds.
configatron.payment_gateway_open_timeout = 5
configatron.payment_gateway_read_timeout = 15
