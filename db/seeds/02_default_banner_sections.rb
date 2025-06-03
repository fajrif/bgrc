# Create Default Banner Section
BannerSection.delete_all
puts "create all banner sections"

@bs1 = BannerSection.create(name: "Home")

@bs2 = BannerSection.create(name: "About")
@bs3 = BannerSection.create(name: "Contact")

@bs4 = BannerSection.create(name: "Facilities")
@bs5 = BannerSection.create(name: "Sports")
@bs6 = BannerSection.create(name: "Events")
@bs7 = BannerSection.create(name: "Promos")
@bs8 = BannerSection.create(name: "Articles")
@bs9 = BannerSection.create(name: "Packages")
