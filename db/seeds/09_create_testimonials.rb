Testimonial.delete_all
puts "create all testimonials"

# Testimonial
8.times do
  testi = Testimonial.create(name: FFaker::Name.name, email: FFaker::Internet.email, company_name: FFaker::Company.name, comment: FFaker::Lorem.paragraphs.join(" "))
  puts "Create testimonial: #{testi.name}"
end
