# CREATE Court Type
CourtType.delete_all

@ct1 = CourtType.create(name: "Indoor")
puts "Create Court Type: #{@ct1.name}"

@ct2 = CourtType.create(name: "Outdoor")
puts "Create Court Type: #{@ct2.name}"
