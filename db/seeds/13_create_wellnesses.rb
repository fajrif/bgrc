Wellness.delete_all
puts "create wellness programs"

[
  { name: "Gym",           name_id: "GYM",           image: "gym.png" },
  { name: "Yoga",          name_id: "Yoga",           image: "yoga.png" },
  { name: "Pilates",       name_id: "Pilates",        image: "pilates.png" },
  { name: "Swimming Pool", name_id: "Kolam Renang",   image: "swimming-pool.png" }
].each do |data|
  next if Wellness.exists?(name: { "en" => data[:name] })

  wellness = Wellness.new(
    name: data[:name],
    short_description: FFaker::Lorem.paragraphs.join(" "),
    description: FFaker::Lorem.paragraphs.join(" ")
  )

  image_path = Rails.root.join("vendor/assets/images/facilities/#{data[:image]}")
  if image_path.exist?
    wellness.image.attach(io: image_path.open, filename: data[:image])
  end

  wellness.save!

  Mobility.with_locale(:id) do
    wellness.name              = data[:name_id]
    wellness.short_description = FFaker::Lorem.paragraphs.join(" ")
    wellness.description       = FFaker::Lorem.paragraphs.join(" ")
    wellness.save!
  end

  puts "Created wellness: #{data[:name]}"
end
