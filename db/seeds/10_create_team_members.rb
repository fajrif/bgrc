TeamMember.delete_all
puts "create all team members"

# Team Member
team_member = TeamMember.new(name: "Danny Sousa", department: "sports", position: 1)
team_member.photo.attach(io: Rails.root.join("vendor/assets/images/coaches/danny-sousa.jpg").open, filename: "danny-sousa.jpg")
team_member.role = "Tennis Coach"
team_member.bio = "Certified tennis coach with MITS Academy, delivering programs from junior development to high-performance training."
Mobility.with_locale(:id) {
	team_member.role = "Pelatih Tenis"
	team_member.bio = "Pelatih tenis bersertifikat dari MITS Academy, memberikan program mulai dari pengembangan junior hingga pelatihan performa tinggi."
}
team_member.save
puts "Create team member: #{team_member.name}"
