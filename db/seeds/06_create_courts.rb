# new Court
Court.delete_all

c = Court.new(:name => "Tennis Court A Indoor")
c.sport = @sport3
c.price = 100000
c.location = "Kuta Selatan"
c.address = "Jl. Pantai Mengiat No. 88 Kawasan Wisata ITDC Nusa Dua Lot"
c.info = "Tennis Court A Indoor at Bali Beach Country Club"
c.instructions = "To enter the premises, kindly please show your vaccine certificate to the security prior to entering. This is a strict regulation. Failure to show vaccine certificate will result in no entry for that person."
c.description = %q{
<p><strong>House Rules:</strong>Rackets and balls are not provided. Please bring your own.</p>
}
Mobility.with_locale(:id) {
  c.info = "Lapangan Tenis Court A Indoor di Klub BGRC"
  c.instructions = "Untuk memasuki tempat tersebut, mohon tunjukkan sertifikat vaksin Anda kepada petugas keamanan sebelum masuk. Ini adalah peraturan yang ketat. Jika tidak menunjukkan sertifikat vaksin, orang tersebut tidak akan diizinkan masuk."
  c.description = %q{
  <p><strong>Aturan Lapangan:</strong>Raket dan bola tidak disediakan. Harap bawa sendiri.</p>
  }
}
5.times do |num|
	c.images.attach(io: Rails.root.join("vendor/assets/images/courts/court1/court#{num+1}.jpg").open, filename: "court#{num+1}.jpg")
end
c.save!

puts "Create court: #{c.name}"

c = Court.new(:name => "Tennis Court B Outdoor")
c.sport = @sport3
c.price = 100000
c.location = "Kuta Selatan"
c.address = "Jl. Pantai Mengiat No. 88 Kawasan Wisata ITDC Nusa Dua Lot"
c.info = "Tennis Court B Outdoor at Bali Beach Country Club"
c.instructions = "To enter the premises, kindly please show your vaccine certificate to the security prior to entering. This is a strict regulation. Failure to show vaccine certificate will result in no entry for that person."
c.description = %q{
<p><strong>House Rules:</strong>Rackets and balls are not provided. Please bring your own.</p>
}
Mobility.with_locale(:id) {
  c.info = "Lapangan Tenis Court B Outdoor di Klub BGRC"
  c.instructions = "Untuk memasuki tempat tersebut, mohon tunjukkan sertifikat vaksin Anda kepada petugas keamanan sebelum masuk. Ini adalah peraturan yang ketat. Jika tidak menunjukkan sertifikat vaksin, orang tersebut tidak akan diizinkan masuk."
  c.description = %q{
  <p><strong>Aturan Lapangan:</strong>Raket dan bola tidak disediakan. Harap bawa sendiri.</p>
  }
}
5.times do |num|
	c.images.attach(io: Rails.root.join("vendor/assets/images/courts/court1/court#{num+1}.jpg").open, filename: "court#{num+1}.jpg")
end
c.save!

puts "Create court: #{c.name}"

c = Court.new(:name => "Padel Court A")
c.sport = @sport1
c.price = 150000
c.location = "Kuta Selatan"
c.address = "Jl. Pantai Mengiat No. 88 Kawasan Wisata ITDC Nusa Dua Lot"
c.info = "Padel Court A at Bali Beach Country Club"
c.instructions = "To enter the premises, kindly please show your vaccine certificate to the security prior to entering. This is a strict regulation. Failure to show vaccine certificate will result in no entry for that person."
c.description = %q{
<p><strong>House Rules:</strong>Rackets and balls are not provided. Please bring your own.</p>
}
Mobility.with_locale(:id) {
  c.info = "Lapangan Padel Court A di Klub BGRC"
  c.instructions = "Untuk memasuki tempat tersebut, mohon tunjukkan sertifikat vaksin Anda kepada petugas keamanan sebelum masuk. Ini adalah peraturan yang ketat. Jika tidak menunjukkan sertifikat vaksin, orang tersebut tidak akan diizinkan masuk."
  c.description = %q{
  <p><strong>Aturan Lapangan:</strong>Raket dan bola tidak disediakan. Harap bawa sendiri.</p>
  }
}
5.times do |num|
	c.images.attach(io: Rails.root.join("vendor/assets/images/courts/court1/court#{num+1}.jpg").open, filename: "court#{num+1}.jpg")
end
c.save!

puts "Create court: #{c.name}"

c = Court.new(:name => "Pickleball Court A")
c.sport = @sport4
c.price = 150000
c.location = "Kuta Selatan"
c.address = "Jl. Pantai Mengiat No. 88 Kawasan Wisata ITDC Nusa Dua Lot"
c.info = "Pickleball Court A at Bali Beach Country Club"
c.instructions = "To enter the premises, kindly please show your vaccine certificate to the security prior to entering. This is a strict regulation. Failure to show vaccine certificate will result in no entry for that person."
c.description = %q{
<p><strong>House Rules:</strong>Rackets and balls are not provided. Please bring your own.</p>
}
Mobility.with_locale(:id) {
  c.info = "Lapangan Pickleball Court A di Klub BGRC"
  c.instructions = "Untuk memasuki tempat tersebut, mohon tunjukkan sertifikat vaksin Anda kepada petugas keamanan sebelum masuk. Ini adalah peraturan yang ketat. Jika tidak menunjukkan sertifikat vaksin, orang tersebut tidak akan diizinkan masuk."
  c.description = %q{
  <p><strong>Aturan Lapangan:</strong>Raket dan bola tidak disediakan. Harap bawa sendiri.</p>
  }
}
5.times do |num|
	c.images.attach(io: Rails.root.join("vendor/assets/images/courts/court1/court#{num+1}.jpg").open, filename: "court#{num+1}.jpg")
end
c.save!

puts "Create court: #{c.name}"
