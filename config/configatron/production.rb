# Override your default settings for the Production environment here.
#
# Example:
#   configatron.file.storage = :s3
# Pre-production sets SITE_URL to its own address so that gateway return URLs and
# emailed links do not point at the live domain.
configatron.site_url = ENV.fetch("SITE_URL", "https://www.balibeachcountryclub.com")
