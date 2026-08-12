# Categories for the Grab & Go order page filter. Upserted by slug, so this file
# is safe to re-run — it never deletes and never duplicates.

def upsert_menu_category!(slug, en_name, id_name:, position:)
	category = MenuCategory.find_by(slug: slug) || MenuCategory.new(slug: slug)
	category.position = position
	category.name = en_name
	category.save!

	Mobility.with_locale(:id) do
		category.name = id_name
		category.save!
	end

	puts "Menu Category: #{category.name} (#{category.slug})"
	category
end

upsert_menu_category!("smoothies-shakes",  "Smoothies & Shakes", id_name: "Smoothie & Shake",   position: 1)
upsert_menu_category!("salad-bowls",       "Salad & Bowls",      id_name: "Salad & Rice Bowl",  position: 2)
upsert_menu_category!("sandwiches-wraps",  "Sandwiches & Wraps", id_name: "Sandwich & Wrap",    position: 3)
upsert_menu_category!("snacks",            "Snacks",             id_name: "Camilan",            position: 4)

puts "Menu categories: #{MenuCategory.count}"
