# Coaching team, three per sport, so every sport's Club Life page lists its own.
#
# Idempotent: upserts on email and never deletes, so it is safe to re-run on
# production alongside coaches an admin has added by hand.
#
# Only four coach photos exist in the repo, so they are reused across sports —
# within any one sport the three faces are distinct, and each photo is paired
# with a matching gender (coach-1 / coach-3 / danny-sousa are men, coach-2 is a
# woman). Replace them with real photography via Admin > Coaches.
puts "ensure all coaches"

COACH_IMAGES = Rails.root.join("vendor/assets/images/coaches")

coaches = [
  # ------------------------------------------------------------------ GOLF
  { sport: "Golf", name: "I Gede Surya Wijaya", email: "gede.wijaya@wearemits.com", phone: "(+62) 813 2211 9087",
    gender: 1, price: 220000, photo: "coach-1.png",
    role_en: "Head Golf Professional", role_id: "Kepala Profesional Golf",
    bio_en: "PGA-trained and twelve years on the bag, Gede rebuilds swings from the ground up and reads our greens better than anyone.",
    bio_id: "Bersertifikat PGA dengan pengalaman dua belas tahun, Gede membangun ulang ayunan dari dasar dan membaca green kami lebih baik dari siapa pun." },
  { sport: "Golf", name: "Putu Ayu Lestari", email: "putu.lestari@wearemits.com", phone: "(+62) 812 8890 4471",
    gender: 0, price: 195000, photo: "coach-2.png",
    role_en: "Short Game Coach", role_id: "Pelatih Short Game",
    bio_en: "Putu specialises in everything inside 100 metres — chipping, bunker play and the putting stroke that saves a round.",
    bio_id: "Putu mengkhususkan diri pada segala hal di bawah 100 meter — chipping, permainan bunker, dan putting yang menyelamatkan permainan." },
  { sport: "Golf", name: "Wayan Adi Nugraha", email: "wayan.nugraha@wearemits.com", phone: "(+62) 811 3345 7712",
    gender: 1, price: 180000, photo: "coach-3.png",
    role_en: "Junior Golf Coach", role_id: "Pelatih Golf Junior",
    bio_en: "Wayan runs our junior pathway, taking players from their first plastic club through to club competition.",
    bio_id: "Wayan menjalankan program junior kami, membimbing pemain dari stik plastik pertama hingga kompetisi klub." },

  # ---------------------------------------------------------------- TENNIS
  { sport: "Tennis", name: "Danny Sousa", email: "danny.sousa@wearemits.com", phone: "(+62) 811 11211",
    gender: 1, price: 200000, photo: "danny-sousa.jpg",
    role_en: "Head Tennis Coach", role_id: "Kepala Pelatih Tenis",
    bio_en: "Certified with MITS Academy, Danny leads the tennis programme from junior development through to high-performance training.",
    bio_id: "Bersertifikat MITS Academy, Danny memimpin program tenis mulai dari pengembangan junior hingga pelatihan performa tinggi." },
  { sport: "Tennis", name: "Kadek Sri Handayani", email: "kadek.handayani@wearemits.com", phone: "(+62) 813 5567 2290",
    gender: 0, price: 185000, photo: "coach-2.png",
    role_en: "Junior Development Coach", role_id: "Pelatih Pengembangan Junior",
    bio_en: "Sri coaches our red, orange and green stage juniors, and runs the weekly after-school clinics.",
    bio_id: "Sri melatih junior tahap merah, oranye, dan hijau, serta menjalankan klinik mingguan sepulang sekolah." },
  { sport: "Tennis", name: "Made Bagus Prayoga", email: "made.prayoga@wearemits.com", phone: "(+62) 812 7781 3390",
    gender: 1, price: 210000, photo: "coach-1.png",
    role_en: "Performance Coach", role_id: "Pelatih Performa",
    bio_en: "Bagus works with competitive adults on tactics, match play and the fitness that holds up in a third set.",
    bio_id: "Bagus bekerja dengan pemain dewasa kompetitif pada taktik, permainan pertandingan, dan kebugaran yang bertahan hingga set ketiga." },

  # ----------------------------------------------------------------- PADEL
  { sport: "Padel", name: "Nyoman Rai Sudana", email: "nyoman.sudana@wearemits.com", phone: "(+62) 811 4432 6678",
    gender: 1, price: 205000, photo: "coach-3.png",
    role_en: "Head Padel Coach", role_id: "Kepala Pelatih Padel",
    bio_en: "Rai came to padel from squash and teaches the wall game better than anyone on the island.",
    bio_id: "Rai beralih ke padel dari squash dan mengajarkan permainan dinding lebih baik dari siapa pun di pulau ini." },
  { sport: "Padel", name: "Luh Putu Dewi Anggraini", email: "luh.anggraini@wearemits.com", phone: "(+62) 813 9902 5518",
    gender: 0, price: 190000, photo: "coach-2.png",
    role_en: "Padel Coach", role_id: "Pelatih Padel",
    bio_en: "Dewi leads our Friday ladies' night and coaches beginners through their first competitive matches.",
    bio_id: "Dewi memimpin ladies' night setiap Jumat dan melatih pemula hingga pertandingan kompetitif pertama mereka." },
  { sport: "Padel", name: "Ketut Arya Wibawa", email: "ketut.wibawa@wearemits.com", phone: "(+62) 812 2218 7734",
    gender: 1, price: 175000, photo: "danny-sousa.jpg",
    role_en: "Padel Coach", role_id: "Pelatih Padel",
    bio_en: "Arya focuses on doubles positioning and the communication that turns two players into a pair.",
    bio_id: "Arya berfokus pada posisi ganda dan komunikasi yang mengubah dua pemain menjadi satu pasangan." },

  # ------------------------------------------------------------ PICKLEBALL
  { sport: "Pickleball", name: "I Kadek Ari Pramana", email: "kadek.pramana@wearemits.com", phone: "(+62) 811 7788 3345",
    gender: 1, price: 190000, photo: "coach-3.png",
    role_en: "Head Pickleball Coach", role_id: "Kepala Pelatih Pickleball",
    bio_en: "Ari guides members from their first rally to advanced doubles strategy, and runs the weekend socials.",
    bio_id: "Ari membimbing member dari reli pertama hingga strategi ganda tingkat lanjut, dan menjalankan acara sosial akhir pekan." },
  { sport: "Pickleball", name: "Gede Bayu Saputra", email: "gede.saputra@wearemits.com", phone: "(+62) 813 3345 9902",
    gender: 1, price: 170000, photo: "coach-1.png",
    role_en: "Pickleball Coach", role_id: "Pelatih Pickleball",
    bio_en: "Bayu teaches the dink, the third-shot drop and the patience the kitchen line demands.",
    bio_id: "Bayu mengajarkan dink, third-shot drop, dan kesabaran yang dituntut oleh garis kitchen." },
  { sport: "Pickleball", name: "Ni Luh Sari Utami", email: "luh.utami@wearemits.com", phone: "(+62) 812 6614 8823",
    gender: 0, price: 165000, photo: "coach-2.png",
    role_en: "Junior Pickleball Coach", role_id: "Pelatih Pickleball Junior",
    bio_en: "Sari runs the junior and family sessions, where most of our members play their very first points.",
    bio_id: "Sari menjalankan sesi junior dan keluarga, tempat sebagian besar member kami memainkan poin pertama mereka." },
]

created = 0
sports  = Sport.all.index_by(&:name)

coaches.each do |attrs|
  coach = Coach.find_or_initialize_by(email: attrs[:email])
  was_new = coach.new_record?

  coach.assign_attributes(
    name: attrs[:name], phone: attrs[:phone], gender: attrs[:gender],
    price: attrs[:price], sport: sports[attrs[:sport]],
    level: [Coach::BEGINNER, Coach::INTERMEDIATE, Coach::PRO].sample
  )
  coach.role = attrs[:role_en]
  coach.bio  = attrs[:bio_en]

  unless coach.photo.attached?
    coach.photo.attach(io: COACH_IMAGES.join(attrs[:photo]).open, filename: attrs[:photo])
  end
  coach.save!

  Mobility.with_locale(:id) do
    coach.role = attrs[:role_id]
    coach.bio  = attrs[:bio_id]
    coach.save!
  end

  created += 1 if was_new
  puts "Coach: #{coach.name} (#{attrs[:sport]})"
end

puts "Coaches: #{created} created, #{Coach.count} total"
