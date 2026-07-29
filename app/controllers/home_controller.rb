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
    @banner = BannerSection.where(name: "Disclaimer").first.banners.first
    @snippet = Snippet.find_by_key("disclaimer")
  end

  def privacy
		# get public privacy
    @banner = BannerSection.where(name: "Privacy Policy").first.banners.first
    @snippet = Snippet.find_by_key("privacy_policy")
  end

  def terms
		# get public terms & conditions — same policy snippets shown in the booking payment modal
    @banner = BannerSection.where(name: "Terms & Conditions").first.banners.first
    @snippets = [Snippet.find_by_key("terms_and_conditions"),
                 Snippet.find_by_key("cancellation_policy"),
                 Snippet.find_by_key("refund_policy")].compact
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
      "spa"        => [facility_image("Yoga"), facility_image("Pilates"), facility_image("Recovery")].compact,
      "dining"     => [facility_image("Restaurant")].compact,
      "events"     => Event.all.map(&:image) + RecurringEvent.active.map(&:image),
      "club_life"  => [facility_image("Pro Shop"), facility_image("Locker Room"),
                        facility_image("Swimming Pool"), facility_image("Golf Course")].compact
    }

    @section = @galleries.key?(params[:category]) ? params[:category] : "all"
    @items = @section == "all" ? @galleries.values.flatten : @galleries[@section]
    @articles = Article.where(status: 1).first(3)
  end

  def our_team
		# get public our team
    @banner = BannerSection.where(name: "Our Team").first.banners.first
    @section = TeamMember::DEPARTMENTS.include?(params[:department]) ? params[:department] : "all"
    @team_members = @section == "all" ? TeamMember.all : TeamMember.where(department: @section)
    @articles = Article.where(status: 1).first(3)
  end

  def mits_academy
		# get public mits academy — real coaches, delivered in partnership with MITS Academy
    @banner = BannerSection.where(name: "MITS Academy").first.banners.first
    @coaches = Coach.all
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
