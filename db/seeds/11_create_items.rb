Item.delete_all
puts "create all items"

# Item
item = Item.create(name: "Racket", price: 20000)
puts "Create item: #{item.name}"

item = Item.create(name: "Ball", price: 10000)
puts "Create item: #{item.name}"

item = Item.create(name: "Ball Boy", price: 50000)
puts "Create item: #{item.name}"

item = Item.create(name: "Hitting Partner", price: 100000)
puts "Create item: #{item.name}"
