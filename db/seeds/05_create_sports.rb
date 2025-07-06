# new Sport
Sport.delete_all

# Article Sport 2
@sport2 = Sport.new(name: "Golf")
@sport2.image.attach(io: Rails.root.join("vendor/assets/images/sports/golf.png").open, filename: "golf.png")
@sport2.short_description = FFaker::Lorem.paragraphs(3).join(" ")
@sport2.description = FFaker::Lorem.paragraphs(30).join(" ")
@sport2.save
Mobility.with_locale(:id) {
  @sport2.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  @sport2.description = FFaker::Lorem.paragraphs(30).join(" ")
}
@sport2.save
puts "new Sport: #{@sport2.name}"

# Article Sport 3
@sport3 = Sport.new(name: "Tennis")
@sport3.image.attach(io: Rails.root.join("vendor/assets/images/sports/tennis.png").open, filename: "tennis.png")
@sport3.short_description = FFaker::Lorem.paragraphs(3).join(" ")
@sport3.description = FFaker::Lorem.paragraphs(30).join(" ")
@sport3.save
Mobility.with_locale(:id) {
  @sport3.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  @sport3.description = FFaker::Lorem.paragraphs(30).join(" ")
}
@sport3.save
puts "new Sport: #{@sport3.name}"

# Article Sport 1
@sport1 = Sport.new(name: "Padel")
@sport1.image.attach(io: Rails.root.join("vendor/assets/images/sports/padel.png").open, filename: "padel.png")
@sport1.short_description = FFaker::Lorem.paragraphs(3).join(" ")
@sport1.description = FFaker::Lorem.paragraphs(30).join(" ")
@sport1.save
Mobility.with_locale(:id) {
  @sport1.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  @sport1.description = FFaker::Lorem.paragraphs(30).join(" ")
}
@sport1.save
puts "new Sport: #{@sport1.name}"

# Article Sport 4
@sport4 = Sport.new(name: "Pickleball")
@sport4.image.attach(io: Rails.root.join("vendor/assets/images/sports/pickleball.png").open, filename: "pickleball.png")
@sport4.short_description = FFaker::Lorem.paragraphs(3).join(" ")
@sport4.description = FFaker::Lorem.paragraphs(30).join(" ")
@sport4.save
Mobility.with_locale(:id) {
  @sport4.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  @sport4.description = FFaker::Lorem.paragraphs(30).join(" ")
}
@sport4.save
puts "new Sport: #{@sport4.name}"
