Article.delete_all
puts "create all Blogs"

# Create Article
title = FFaker::Book.title
news1 = Article.new(title: title, category: @cat3)
news1.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-4.png").open, filename: "banner-4.png")
news1.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news1.content = FFaker::Lorem.paragraphs(30).join(" ")
news1.save
Mobility.with_locale(:id) {
  news1.title = title
  news1.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news1.content = FFaker::Lorem.paragraphs(30).join(" ")
  news1.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news1.save
}
puts "Create Blog: #{news1.title}"

# Create Article
title = FFaker::Book.title
news2 = Article.new(title: title, category: @cat2)
news2.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-5.png").open, filename: "banner-5.png")
news2.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news2.content = FFaker::Lorem.paragraphs(30).join(" ")
news2.save
Mobility.with_locale(:id) {
  news2.title = title
  news2.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news2.content = FFaker::Lorem.paragraphs(30).join(" ")
  news2.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news2.save
}
puts "Create Blog: #{news2.title}"

# Create Article
title = FFaker::Book.title
news3 = Article.new(title: title, category: @cat2)
news3.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-6.png").open, filename: "banner-6.png")
news3.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news3.content = FFaker::Lorem.paragraphs(30).join(" ")
news3.save
Mobility.with_locale(:id) {
  news3.title = title
  news3.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news3.content = FFaker::Lorem.paragraphs(30).join(" ")
  news3.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news3.save
}
puts "Create Blog: #{news3.title}"

# Create Article
title = FFaker::Book.title
news4 = Article.new(title: title, category: @cat1)
news4.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-7.png").open, filename: "banner-7.png")
news4.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news4.content = FFaker::Lorem.paragraphs(30).join(" ")
news4.save
Mobility.with_locale(:id) {
  news4.title = title
  news4.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news4.content = FFaker::Lorem.paragraphs(30).join(" ")
  news4.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news4.save
}
puts "Create Blog: #{news4.title}"

# Create Article
title = FFaker::Book.title
news5 = Article.new(title: title, category: @cat3)
news5.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-8.png").open, filename: "banner-8.png")
news5.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news5.content = FFaker::Lorem.paragraphs(30).join(" ")
news5.save
Mobility.with_locale(:id) {
  news5.title = title
  news5.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news5.content = FFaker::Lorem.paragraphs(30).join(" ")
  news5.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news5.save
}
puts "Create Blog: #{news5.title}"

# Create Article
title = FFaker::Book.title
news6 = Article.new(title: title, category: @cat3)
news6.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-9.png").open, filename: "banner-9.png")
news6.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news6.content = FFaker::Lorem.paragraphs(30).join(" ")
news6.save
Mobility.with_locale(:id) {
  news6.title = title
  news6.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news6.content = FFaker::Lorem.paragraphs(30).join(" ")
  news6.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news6.save
}
puts "Create Blog: #{news6.title}"
