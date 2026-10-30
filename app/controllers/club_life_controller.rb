class ClubLifeController < ApplicationController
  include LocalizedLookup

  before_action :set_banner

  # Two Golf children were given shorter slugs when Club Life sections moved
  # under their parent (/club-life/golf/course). Their old URLs still resolve.
  RENAMED_SLUGS = { "golf-course" => "course", "golf-lessons-academy" => "lessons" }.freeze

  def index
    # get public club life — the five top-level sections, in display order
    @sections = Facility.club_life_roots.includes(:children, image_attachment: :blob)
    @articles = Article.where(status: 1).first(3)
  end

  def show
    @section = resolve_section
    return if performed?
    raise ActiveRecord::RecordNotFound unless @section.in_club_life?

    @root      = @section.club_life_root
    @children  = @section.children
    @amenities  = @section.amenities
    @details    = @section.facility_details
    @treatments = @section.treatments
    @gallery    = @section.gallery_images

    # Linked sports carry the real class programme; unlinked sections show none.
    @group_classes = @section.sport_id.present? ? GroupClass.available.where(sport_id: @section.sport_id).includes(:sport) : GroupClass.none
    @specialists   = @root&.en_name == "Spa + Wellness" && @section != @root && @section.show_specialists? ? TeamMember.where(department: "specialists") : TeamMember.none
    @show_mits     = @root&.en_name == "Racquet Sports"

    # Racquet Sports fronts its children as hover-overlay photo cards; Golf and
    # Spa + Wellness keep the service card with its own CTA.
    @use_overlay_cards = @show_mits || @root&.en_name == "Spa + Wellness" && @root == @section

    # A section tied to a sport is a bookable venue: it gets a class programme
    # and a coaching team of its own. Rates come from the section's own
    # membership pricing when it has any, otherwise from the sport's courts.
    @rate_cards  = @section.rate_cards
    @sport_rates = @section.rate_cards_from_sport?
    # Golf and Racquet Sports children are plain pages: light header, no hero,
    # a wide banner band under the intro. Racquet children also get the sub-tabs.
    @band_layout  = @root.present? && @root != @section && %w[Golf Racquet\ Sports Fitness Spa\ +\ Wellness].include?(@root.en_name)
    @show_subtabs = @band_layout && %w[Racquet\ Sports Fitness Spa\ +\ Wellness].include?(@root.en_name)

    # Spa + Wellness: the root fronts its three children as service cards under a
    # wide photo; the children are band pages with no gallery of their own.
    @spa_root  = @root.present? && @root == @section && @root.en_name == "Spa + Wellness"
    @spa_child = @band_layout && @root.en_name == "Spa + Wellness"
    @gallery   = [] if @spa_child

    # Fitness has no sport behind it: its children list the shared Fitness team
    # (Our Team → Fitness) instead of coaches, and the root fronts its children
    # as a slider with the team underneath.
    @fitness_root  = @root.present? && @root == @section && @root.en_name == "Fitness"
    @fitness_child = @band_layout && @root.en_name == "Fitness"
    @fitness_team  = @fitness_root || (@fitness_child && @section.show_coaches?) ? TeamMember.where(department: "fitness").with_attached_photo : TeamMember.none
    @benefits      = @section.benefits.with_attached_icon

    # Golf Course is linked to the Golf sport only for its gallery, so on Golf's
    # child pages the coaches row is opt-in (Golf Lessons borrows its parent's sport).
    coach_sport_id = @section.sport_id.presence || (@root.sport_id if @section.show_coaches?)
    coaches_wanted = @band_layout && @root.en_name == "Golf" ? @section.show_coaches? : coach_sport_id.present?
    @coaches     = coaches_wanted ? Coach.for_sport(coach_sport_id).with_attached_photo : Coach.none
    @golf_siblings = @band_layout && @root.en_name == "Golf" ? @root.children : []

    @meta_title = @section.name
    @meta_desc  = @section.short_description
    @articles   = Article.where(status: 1).first(3)
  end

  private

  # A page is addressed as /club-life/<section> or /club-life/<section>/<child>.
  # Anything that reaches the right record by another address — a child at its
  # pre-nesting flat URL, a renamed slug, or the other locale's slug — is sent
  # on to the canonical one, so each page answers at exactly one address.
  def resolve_section
    section = find_facility(params[:section])
    raise ActiveRecord::RecordNotFound if section.nil?

    if params[:id].present?
      child = find_facility(params[:id])
      raise ActiveRecord::RecordNotFound unless child && child.parent_id == section.id
      target = child
    else
      target = section
    end

    canonical = helpers.club_life_page_path(target)
    return redirect_to canonical, status: :moved_permanently if request.path != canonical
    target
  end

  def find_facility(slug)
    find_by_localized_slug(Facility, RENAMED_SLUGS.fetch(slug, slug))
  end

  def set_banner
    @banner = BannerSection.where(name: "Club Life").first&.banners&.first
  end
end
