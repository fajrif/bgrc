Coach.delete_all
puts "create all coaches"

# Coach
coach = Coach.new(name: "Danny Sousa", email: "danny.sousa@wearemits.com", phone: "(+62) 811 11211", gender: 1, price: 200000)
coach.photo.attach(io: Rails.root.join("vendor/assets/images/coaches/danny-sousa.jpg").open, filename: "danny-sousa.jpg")
coach.save
puts "Create coach: #{coach.name}"
