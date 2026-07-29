class HomeController < ApplicationController

  def index
		# get public home — data-backed sections only; other sections are static.
    @testimonials = Testimonial.first(6)
    @articles = Article.where(status: 1).first(3)
    @faqs = Question.where(section: "general").limit(6)
  end

  def about
		# get public about
    @banner = BannerSection.where(name: "About").first.banners.first
    @articles = Article.where(status: 1).first(3)
  end

  def disclaimer
		# get public disclaimer
  end

  def privacy
		# get public privacy
  end

  def faq
		# get public faq
    @banner = BannerSection.where(name: "FAQ").first.banners.first
    @section = Question::SECTIONS.include?(params[:section]) ? params[:section] : "general"
    @faqs = Question.where(section: @section)
  end

  def gallery
		# get public gallery — every category pulls real, already-uploaded photos
		# (Sport galleries, Facility photos, Event photos). No stock placeholders.
    @banner = BannerSection.where(name: "Gallery").first.banners.first

    @galleries = {
      "golf"       => sport_images("Golf"),
      "tennis"     => sport_images("Tennis"),
      "padel"      => sport_images("Padel"),
      "pickleball" => sport_images("Pickleball"),
      "fitness"    => [facility_image("GYM")].compact,
      "spa"        => [facility_image("Yoga"), facility_image("Pilates"), facility_image("Sauna")].compact,
      "dining"     => [facility_image("Restaurant")].compact,
      "events"     => Event.all.map(&:image) + RecurringEvent.active.map(&:image),
      "club_life"  => [facility_image("Pro Shop"), facility_image("Locker Room"),
                        facility_image("Swimming Pool"), facility_image("Golf Course")].compact
    }

    @section = @galleries.key?(params[:category]) ? params[:category] : "all"
    @items = @section == "all" ? @galleries.values.flatten : @galleries[@section]
    @articles = Article.where(status: 1).first(3)
  end

  private

  def sport_images(name)
    Sport.find_by(name: name)&.images&.to_a || []
  end

  def facility_image(name)
    Facility.find_by("name @> ?", { en: name }.to_json)&.image
  end
end
