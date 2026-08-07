# Ensure Default Banner Sections
# Idempotent: only creates sections that don't already exist by name, never deletes.
# Safe to re-run on production (e.g. after adding a new page's section here).
puts "ensure all banner sections"

[
  "Home",
  "About", "Contact",
  "Facilities", "Sports", "Events", "Promos", "Articles", "Packages",
  "Golf", "Tennis", "Padel", "Pickleball",
  "FAQ", "Gallery", "Our Team", "MITS Academy",
  "Disclaimer", "Privacy Policy", "Terms & Conditions",
  "Club Life", "Highlights", "Dining",
].each do |name|
  section = BannerSection.find_or_create_by!(name: name)
  puts "Banner section: #{section.name}"
end
