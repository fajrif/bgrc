Article.delete_all
puts "create all Blogs"

# Resolve categories directly rather than relying on @cat1-@cat4 having been
# set by 04_create_categories.rb in the same process — this file is often run
# standalone (e.g. `bin/rails runner 'load ...05_create_articles.rb'`), and
# `belongs_to :category` is required, so a nil category used to fail `.save`
# silently (no exception) while the puts below still printed regardless.
def find_or_create_category!(en_name, id_name)
	Category.find_by("name @> ?", { en: en_name }.to_json) || Category.find_by(name: en_name) ||
		Category.create!(name: en_name).tap { |c| Mobility.with_locale(:id) { c.name = id_name; c.save! } }
end

@cat1 ||= find_or_create_category!("Padel", "Padel")
@cat2 ||= find_or_create_category!("Golf", "Golf")
@cat3 ||= find_or_create_category!("Tennis", "Tenis")
@cat4 ||= find_or_create_category!("Pickleball", "Pickleball")

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

# Create Article
title = FFaker::Book.title
news7 = Article.new(title: title, category: @cat4)
news7.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-1.png").open, filename: "banner-1.png")
news7.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news7.content = FFaker::Lorem.paragraphs(30).join(" ")
news7.save
Mobility.with_locale(:id) {
  news7.title = title
  news7.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news7.content = FFaker::Lorem.paragraphs(30).join(" ")
  news7.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news7.save
}
puts "Create Blog: #{news7.title}"

# Create Article
title = FFaker::Book.title
news8 = Article.new(title: title, category: @cat1)
news8.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-2.png").open, filename: "banner-2.png")
news8.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news8.content = FFaker::Lorem.paragraphs(30).join(" ")
news8.save
Mobility.with_locale(:id) {
  news8.title = title
  news8.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news8.content = FFaker::Lorem.paragraphs(30).join(" ")
  news8.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news8.save
}
puts "Create Blog: #{news8.title}"

# Create Article
title = FFaker::Book.title
news9 = Article.new(title: title, category: @cat2)
news9.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-3.png").open, filename: "banner-3.png")
news9.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news9.content = FFaker::Lorem.paragraphs(30).join(" ")
news9.save
Mobility.with_locale(:id) {
  news9.title = title
  news9.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news9.content = FFaker::Lorem.paragraphs(30).join(" ")
  news9.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news9.save
}
puts "Create Blog: #{news9.title}"

# Create Article
title = FFaker::Book.title
news10 = Article.new(title: title, category: @cat3)
news10.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-10.png").open, filename: "banner-10.png")
news10.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news10.content = FFaker::Lorem.paragraphs(30).join(" ")
news10.save
Mobility.with_locale(:id) {
  news10.title = title
  news10.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news10.content = FFaker::Lorem.paragraphs(30).join(" ")
  news10.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news10.save
}
puts "Create Blog: #{news10.title}"

# Create Article
title = FFaker::Book.title
news11 = Article.new(title: title, category: @cat1)
news11.image.attach(io: Rails.root.join("vendor/assets/images/images/image-1.png").open, filename: "image-1.png")
news11.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news11.content = FFaker::Lorem.paragraphs(30).join(" ")
news11.save
Mobility.with_locale(:id) {
  news11.title = title
  news11.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news11.content = FFaker::Lorem.paragraphs(30).join(" ")
  news11.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news11.save
}
puts "Create Blog: #{news11.title}"

# Create Article
title = FFaker::Book.title
news12 = Article.new(title: title, category: @cat4)
news12.image.attach(io: Rails.root.join("vendor/assets/images/images/image-2.png").open, filename: "image-2.png")
news12.short_description = FFaker::Lorem.paragraphs(3).join(" ")
news12.content = FFaker::Lorem.paragraphs(30).join(" ")
news12.save
Mobility.with_locale(:id) {
  news12.title = title
  news12.short_description = FFaker::Lorem.paragraphs(3).join(" ")
  news12.content = FFaker::Lorem.paragraphs(30).join(" ")
  news12.published_date = DateTime.strptime('05/21/2024 1:46 AM', '%m/%d/%Y %I:%M %p')
  news12.save
}
puts "Create Blog: #{news12.title}"
