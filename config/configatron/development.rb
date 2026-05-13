# Override your default settings for the Development environment here.
#
# Example:
#   configatron.file.storage = :local
configatron.site_url = "localhost:3000"
configatron.midtrans_api_url = "https://app.sandbox.midtrans.com/snap/v1/transactions"
configatron.midtrans_js_file = "https://app.sandbox.midtrans.com/snap/snap.js"
configatron.midtrans_merchant_id = ENV['MIDTRANS_MERCHANT_ID']
configatron.midtrans_client_key = ENV['MIDTRANS_CLIENT_KEY']
configatron.midtrans_server_key = ENV['MIDTRANS_SERVER_KEY']
