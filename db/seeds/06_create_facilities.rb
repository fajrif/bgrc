puts "create all facilities"

def upsert_facility!(en_name, id_name:, image:)
	facility = Facility.find_by("name @> ?", { en: en_name }.to_json) || Facility.new
	facility.name = en_name
	facility.short_description = FFaker::Lorem.paragraphs.join(" ") if facility.short_description.blank?
	facility.description = FFaker::Lorem.paragraphs.join(" ") if facility.description.blank?
	if !facility.image.attached?
		facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/#{image}").open, filename: image)
	end
	facility.save!

	Mobility.with_locale(:id) {
		facility.name = id_name
		facility.short_description = FFaker::Lorem.paragraphs.join(" ") if facility.short_description.blank?
		facility.description = FFaker::Lorem.paragraphs.join(" ") if facility.description.blank?
	}
	facility.save!

	puts "Create facility: #{facility.name}"
	facility
end

# Named for whatever they end up as once Club Life adopts them (see
# 16_create_club_life.rb), not their historical names — otherwise re-running
# this seed after that adoption/rename has happened creates a stray duplicate
# under the old name instead of finding and no-op'ing on the real record.
upsert_facility!("Golf Course", id_name: "Lapangan Golf", image: "golf-course.png")
upsert_facility!("Tennis", id_name: "Tenis", image: "tennis-court.png")
upsert_facility!("Padel", id_name: "Padel", image: "padel-court.png")
upsert_facility!("Pickleball", id_name: "Pickleball", image: "pickleball-court.png")
upsert_facility!("Gym", id_name: "Gym", image: "gym.png")
upsert_facility!("Lap Pool", id_name: "Kolam Renang", image: "swimming-pool.png")
upsert_facility!("Yoga", id_name: "Yoga", image: "yoga.png")
upsert_facility!("Pilates", id_name: "Pilates", image: "pilates.png")
upsert_facility!("Pro Shop", id_name: "Toko Alat", image: "pro-shop.png")
upsert_facility!("Recovery", id_name: "Pemulihan", image: "recovery-center.png")
upsert_facility!("Locker Room", id_name: "Ruang Ganti", image: "lockers.png")

# "Restaurant" is retired — dining is now its own Restaurant model with real
# pages at /dining, not a single generic Facility. Clean up the old record.
Facility.find_by("name @> ?", { en: "Restaurant" }.to_json)&.destroy
