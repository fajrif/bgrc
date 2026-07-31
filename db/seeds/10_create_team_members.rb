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

coaches.each do |attrs|
	team_member = TeamMember.new(name: attrs[:name], department: "sports", position: attrs[:position])
	team_member.photo.attach(io: Rails.root.join("vendor/assets/images/coaches/#{attrs[:photo]}").open, filename: attrs[:photo])
	team_member.role = attrs[:role_en]
	team_member.bio = attrs[:bio_en]
	Mobility.with_locale(:id) {
		team_member.role = attrs[:role_id]
		team_member.bio = attrs[:bio_id]
	}
	team_member.save
	puts "Create team member: #{team_member.name}"
end
