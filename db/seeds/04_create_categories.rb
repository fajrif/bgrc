# CREATE Category
Category.delete_all

# Article Category 1
@cat1 = Category.create(name: "Padel")
Mobility.with_locale(:id) {
	@cat1.name = "Padel"
}
@cat1.save
puts "Create Category: #{@cat1.name}"

# Article Category 2
@cat2 = Category.create(name: "Golf")
Mobility.with_locale(:id) {
	@cat2.name = "Golf"
}
@cat2.save
puts "Create Category: #{@cat2.name}"

# Article Category 3
@cat3 = Category.create(name: "Tennis")
Mobility.with_locale(:id) {
	@cat3.name = "Tenis"
}
@cat3.save
puts "Create Category: #{@cat3.name}"

# Article Category 4
@cat4 = Category.create(name: "Pickleball")
Mobility.with_locale(:id) {
	@cat4.name = "Pickleball"
}
@cat4.save
puts "Create Category: #{@cat4.name}"
