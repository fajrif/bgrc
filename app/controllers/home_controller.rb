class HomeController < ApplicationController

  def index
		# get public home — data-backed sections only; other sections are static.
    @testimonials = Testimonial.order(created_at: :desc).limit(10)
    @articles = Article.where(status: 1).first(6)
    @faqs = Question.where(section: "general").limit(6)
    @restaurants = Restaurant.order(:position)
    roots = Facility.club_life_roots.to_a
    @golf_facility    = roots.find { |f| f.en_name == "Golf" }
    @fitness_facility = roots.find { |f| f.en_name == "Fitness" }
    @spa_facility     = roots.find { |f| f.en_name == "Spa + Wellness" }
  end

  def about
		# get public about
    @articles = Article.where(status: 1).first(3)
  end

  def disclaimer
		# get public disclaimer
    @snippet = Snippet.find_by_key("disclaimer")
  end

  def privacy
		# get public privacy
    @snippet = Snippet.find_by_key("privacy_policy")
  end

  def terms
		# get public terms & conditions — same policy snippets shown in the booking payment modal
    @snippets = [Snippet.find_by_key("terms_and_conditions"),
                 Snippet.find_by_key("cancellation_policy"),
                 Snippet.find_by_key("refund_policy")].compact
  end

  def faq
		# get public faq
    @section = Question::SECTIONS.include?(params[:section]) ? params[:section] : "general"
    @faqs = Question.where(section: @section)
  end

  def gallery
		# get public gallery — every category pulls real, already-uploaded photos
		# (Sport galleries, Facility photos, Event photos). No stock placeholders.

    @galleries = {
      "golf"       => sport_images("Golf"),
      "tennis"     => sport_images("Tennis"),
      "padel"      => sport_images("Padel"),
      "pickleball" => sport_images("Pickleball"),
      "fitness"    => facility_images("Fitness", fallback: ["Gym"]),
      "spa"        => facility_images("Spa", fallback: ["Yoga", "Pilates", "Recovery Center", "Recovery"]),
      "dining"     => Restaurant.all.filter_map { |r| r.image if r.image.attached? },
      "events"     => event_images,
      "club_life"  => facility_images("Beach Club", fallback: ["Pro Shop", "Locker Room", "Lap Pool", "Golf Course"])
    }

    @section = @galleries.key?(params[:category]) ? params[:category] : "all"
    # "All" mixes the categories one photo at a time so the first rows are not all one sport
    @items = @section == "all" ? interleave(@galleries.values) : @galleries[@section]
    @articles = Article.where(status: 1).first(3)
  end

  def our_team
		# get public our team
    @section = TeamMember::DEPARTMENTS.include?(params[:department]) ? params[:department] : "all"
    @team_members = @section == "all" ? TeamMember.all : TeamMember.where(department: @section)
    @articles = Article.where(status: 1).first(3)
  end

  def mits_academy
		# get public mits academy — real coaches, delivered in partnership with MITS Academy
    # MITS partners with us on the racquet sports only. Stated positively so
    # coaches with no sport are excluded too, rather than by a NOT IN that
    # would drop them on a NULL comparison by accident.
    @coaches = Coach.where(sport_id: Sport.where.not(name: "Golf").select(:id))
    @articles = Article.where(status: 1).first(3)
  end

  private

  def sport_images(name)
    Sport.find_by(name: name)&.images&.to_a || []
  end

  def facility_image(name)
    Facility.find_by("name @> ?", { en: name }.to_json)&.image
  end

  # A facility's own gallery, or its card photo (and its siblings') when it has none.
  def facility_images(name, fallback: [])
    gallery = Facility.find_by("name @> ?", { en: name }.to_json)&.ordered_images&.to_a || []
    return gallery if gallery.any?
    ([name] + fallback).filter_map { |n| facility_image(n) }.select(&:attached?)
  end

  def event_images
    types = EventType.all.flat_map { |type| type.images.attached? ? type.images.to_a : [type.image].select(&:attached?) }
    types + Event.all.map(&:image) + RecurringEvent.active.map(&:image)
  end

  def interleave(lists)
    longest = lists.map(&:size).max.to_i
    (0...longest).flat_map { |i| lists.filter_map { |list| list[i] } }
  end
end
