Coach.delete_all
puts "create all coaches"

coaches = [
  # photos are matched to gender: coach-1/coach-3 are men, coach-2 is a woman
  { name: "Danny Sousa", email: "danny.sousa@wearemits.com", phone: "(+62) 811 11211", gender: 1, price: 200000, photo: "danny-sousa.jpg" },
  { name: "I Gede Surya Wijaya", email: "gede.wijaya@wearemits.com", phone: "(+62) 813 2211 9087", gender: 1, price: 220000, photo: "coach-1.png" },
  { name: "Ni Made Ayu Pratiwi", email: "made.pratiwi@wearemits.com", phone: "(+62) 812 3456 7890", gender: 0, price: 175000, photo: "coach-2.png" },
  { name: "I Kadek Ari Pramana", email: "kadek.pramana@wearemits.com", phone: "(+62) 811 7788 3345", gender: 1, price: 190000, photo: "coach-3.png" },
]

coaches.each do |attrs|
  photo = attrs.delete(:photo)
  coach = Coach.new(attrs)
  coach.photo.attach(io: Rails.root.join("vendor/assets/images/coaches/#{photo}").open, filename: photo)
  coach.save
  puts "Create coach: #{coach.name}"
end
