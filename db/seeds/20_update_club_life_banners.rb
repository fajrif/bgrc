# Sets the hero banner photo for each Club Life Facility page — a dedicated
# `banner` attachment, separate from `image` (which stays whatever it already
# is: the card/thumbnail photo used on the Club Life mosaic, sidebar, etc.).
#
# Like the old version of this file, this always purges whatever banner is
# currently attached and re-attaches the named file — these are curated,
# final photos, not a "fill in if missing" default. If an admin has since
# uploaded a different banner via /admins/facilities, this will overwrite it
# back to the file listed here on every run.
puts "update club life facility banners"

NEW_BANNERS = Rails.root.join("vendor/assets/images/new-banners")

def replace_facility_banner!(en_name, file)
	facility = Facility.find_by("name @> ?", { en: en_name }.to_json)
	unless facility
		puts "Skipped #{en_name.inspect} — no Facility found with that name"
		return
	end

	facility.banner.purge if facility.banner.attached?
	facility.banner.attach(io: NEW_BANNERS.join(file).open, filename: file)
	puts "Facility banner: #{en_name} -> #{file}"
end

# ------------------------------------------------------------------ GOLF
replace_facility_banner!("Golf",                     "banner-golf.png")
replace_facility_banner!("Golf Course",               "banner-golf-course.png")
replace_facility_banner!("Golf Lessons & Academy",    "banner-golf-academy.png")
replace_facility_banner!("Driving Range",             "banner-driving-range.png")

# --------------------------------------------------------- RACQUET SPORTS
replace_facility_banner!("Racquet Sports",            "banner-racquet-sports.png")
replace_facility_banner!("Tennis",                    "banner-tennis.png")
replace_facility_banner!("Padel",                     "banner-padel.png")
replace_facility_banner!("Pickleball",                "banner-pickleball.png")

# ------------------------------------------------------------- BEACH CLUB
replace_facility_banner!("Beach Club",                "banner-beach-club.png")

# --------------------------------------------------------------- FITNESS
replace_facility_banner!("Fitness",                   "banner-fitness.png")
replace_facility_banner!("Gym",                       "banner-gym.png")
replace_facility_banner!("Gyrotonic",                 "banner-gyrotonic.png")
replace_facility_banner!("Pilates",                   "banner-pilates.png")
replace_facility_banner!("Yoga",                      "banner-yoga.png")
replace_facility_banner!("Lap Pool",                  "banner-lap-pool.png")

# --------------------------------------------------------- SPA + WELLNESS
replace_facility_banner!("Spa + Wellness",            "banner-spa-wellness.png")
replace_facility_banner!("Spa",                       "banner-spa.png")
replace_facility_banner!("Recovery",                  "banner-recovery.png")
replace_facility_banner!("Anti Aging",                "banner-anti-aging.png")
