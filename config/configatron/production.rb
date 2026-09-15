# Override your default settings for the Production environment here.
#
# Example:
#   configatron.file.storage = :s3

# Set SITE_URL in the server's .env; this is only the fallback.
configatron.site_url = ENV["SITE_URL"].presence || "https://www.balibeachcountryclub.com"
