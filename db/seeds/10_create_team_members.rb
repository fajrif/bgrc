TeamMember.delete_all
puts "create all team members"

# Coaches — mirrors the Coach records in 10_create_coaches.rb so they also
# appear on the public Our Team page. Photos are matched to gender: coach-1
# and coach-3 are men, coach-2 is a woman.
coaches = [
	{
		name: "Danny Sousa", position: 1, photo: "danny-sousa.jpg",
		role_en: "Tennis Coach",
		bio_en: "Certified tennis coach with MITS Academy, delivering programs from junior development to high-performance training.",
		role_id: "Pelatih Tenis",
		bio_id: "Pelatih tenis bersertifikat dari MITS Academy, memberikan program mulai dari pengembangan junior hingga pelatihan performa tinggi.",
	},
	{
		name: "I Gede Surya Wijaya", position: 2, photo: "coach-1.png",
		role_en: "Golf Instructor",
		bio_en: "PGA-trained golf instructor helping members refine their swing, short game and course strategy at Bali Beach Country Club.",
		role_id: "Instruktur Golf",
		bio_id: "Instruktur golf bersertifikat PGA yang membantu member menyempurnakan swing, short game, dan strategi permainan di Bali Beach Country Club.",
	},
	{
		name: "Ni Made Ayu Pratiwi", position: 3, photo: "coach-2.png",
		role_en: "Fitness & Yoga Coach",
		bio_en: "Fitness and yoga coach at MITS Academy, blending strength training with mindful movement to help members build balance and resilience.",
		role_id: "Pelatih Fitness & Yoga",
		bio_id: "Pelatih fitness dan yoga di MITS Academy, memadukan latihan kekuatan dengan gerakan penuh kesadaran untuk membantu member membangun keseimbangan dan daya tahan.",
	},
	{
		name: "I Kadek Ari Pramana", position: 4, photo: "coach-3.png",
		role_en: "Pickleball Coach",
		bio_en: "Pickleball coach at MITS Academy, guiding members from their first rally to advanced doubles strategy.",
		role_id: "Pelatih Pickleball",
		bio_id: "Pelatih pickleball di MITS Academy, membimbing member mulai dari reli pertama hingga strategi ganda tingkat lanjut.",
	},
]

# Specialists — the wellness team fronted on the Anti Aging page and on
# Our Team. Photos reuse the coach portraits until real ones are supplied.
specialists = [
	{
		name: "dr. Putu Ananda Sari", position: 1, photo: "coach-2.png",
		role_en: "Longevity Physician",
		bio_en: "Leads our anti-aging consultations, planning programmes around bloodwork, movement and recovery rather than single treatments.",
		role_id: "Dokter Longevity",
		bio_id: "Memimpin konsultasi anti-aging kami, merancang program berdasarkan hasil laboratorium, gerak, dan pemulihan, bukan sekadar perawatan tunggal.",
	},
	{
		name: "I Wayan Adi Nugraha", position: 2, photo: "coach-1.png",
		role_en: "Recovery Therapist",
		bio_en: "Works with members training through the week, combining deep tissue therapy with contrast bathing and guided stretching.",
		role_id: "Terapis Pemulihan",
		bio_id: "Menangani anggota yang berlatih sepanjang minggu, memadukan terapi deep tissue dengan mandi kontras dan peregangan terpandu.",
	},
	{
		name: "I Made Bagus Wirawan", position: 3, photo: "coach-3.png",
		role_en: "Spa & Skin Specialist",
		bio_en: "Plans facial and skin renewal courses, and trains the treatment team on every protocol offered at the spa.",
		role_id: "Spesialis Spa & Kulit",
		bio_id: "Merancang rangkaian facial dan peremajaan kulit, serta melatih tim perawatan pada setiap protokol yang ditawarkan di spa.",
	},
]

def create_team_member!(attrs, department:)
	team_member = TeamMember.new(name: attrs[:name], department: department, position: attrs[:position])
	team_member.photo.attach(io: Rails.root.join("vendor/assets/images/coaches/#{attrs[:photo]}").open, filename: attrs[:photo])
	team_member.role = attrs[:role_en]
	team_member.bio = attrs[:bio_en]
	Mobility.with_locale(:id) {
		team_member.role = attrs[:role_id]
		team_member.bio = attrs[:bio_id]
	}
	team_member.save!
	puts "Create team member: #{team_member.name} (#{department})"
end

coaches.each { |attrs| create_team_member!(attrs, department: "sports") }
specialists.each { |attrs| create_team_member!(attrs, department: "specialists") }
