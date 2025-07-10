# new Court
Court.delete_all

10.times do |num|
  _name = "Court #{("A".."Z").to_a[num]}"
  c = Court.new(:name => _name, court_type: @ct1)
  c.sport = @sport3
  c.price = 100000
  c.location = "Kuta Selatan"
  c.save!
  puts "Create court: #{c.name}"
end

11.upto(12) do |num|
  _name = "Court #{("A".."Z").to_a[num]}"
  c = Court.new(:name => _name, court_type: @ct2)
  c.sport = @sport3
  c.price = 100000
  c.location = "Kuta Selatan"
  c.save!
  puts "Create court: #{c.name}"
end

5.times do |num|
  _name = "Court #{("A".."Z").to_a[num]}"
  c = Court.new(:name => _name, court_type: @ct1)
  c.sport = @sport1
  c.price = 150000
  c.location = "Kuta Selatan"
  c.save!
  puts "Create court: #{c.name}"
end

4.times do |num|
  _name = "Court #{("A".."Z").to_a[num]}"
  c = Court.new(:name => _name, court_type: @ct1)
  c.sport = @sport4
  c.price = 130000
  c.location = "Kuta Selatan"
  c.save!
  puts "Create court: #{c.name}"
end
