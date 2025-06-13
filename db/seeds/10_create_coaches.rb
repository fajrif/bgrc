Coach.delete_all
puts "create all coaches"

# Coach
coach = Coach.new(name: "John Doe", email: "john.doe@bgrc.com", phone: "(+62) 811 11211", gender: 1, price: 100000)
coach.photo.attach(io: Rails.root.join("vendor/assets/images/coaches/coach1.jpg").open, filename: "coach1.jpg")
coach.save
puts "Create coach: #{coach.name}"

coach = Coach.new(name: "Jane Doe", email: "jane.doe@bgrc.com", phone: "(+62) 811 22211", gender: 0, price: 110000)
coach.photo.attach(io: Rails.root.join("vendor/assets/images/coaches/coach2.jpg").open, filename: "coach2.jpg")
coach.save
puts "Create coach: #{coach.name}"
