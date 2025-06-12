Coach.delete_all
puts "create all coaches"

# Coach
2.times do
  coach = Coach.create(name: FFaker::Name.name, email: FFaker::Internet.email, phone: "(+62) 811 11211")
  puts "Create coach: #{coach.name}"
end
