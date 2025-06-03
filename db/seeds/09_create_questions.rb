Question.delete_all
puts "create all questions"

sections = [
  "general",
  "booking",
  "payment",
  "promo",
  "packages",
  "facilities",
  "sports",
  "location"
]

# FAQ
sections.each do |section|
  num = rand(5) + 5
  num.times do
    _title = FFaker::Book.unique.title
    faq = Question.new(title: "How to #{_title}", section: section)
    faq.description = FFaker::Lorem.paragraphs.join(" ")
    faq.save
    Mobility.with_locale(:id) {
      faq.title = "Apakah #{_title}"
      faq.description = FFaker::Lorem.paragraphs.join(" ")
    }
    faq.save
    puts "Create FAQ: #{faq.title}"
  end
end
