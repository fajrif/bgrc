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
