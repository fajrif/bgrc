# The booking hub. Golf and Racquet Sports have real booking engines of their
# own (GolfController, SearchController) and only appear here as tabs; the three
# actions below cover the categories that are booked by enquiry instead.
class BookController < ApplicationController
  before_action :set_banner
  before_action :set_articles

  def index
    # Tile photos come from the Club Life records themselves, so a section whose
    # photo is changed in admin updates here too.
    @golf       = club_life_root("Golf")
    @racquet    = club_life_root("Racquet Sports")
    @fitness    = club_life_root("Fitness")
    @spa        = club_life_root("Spa + Wellness")
    @meta_title = "Book"
    @meta_desc  = "Book a tee time, a court, a class, a treatment or a table at Bali Beach Country Club"
  end

  def fitness
    @section    = club_life_root("Fitness")
    @children   = @section&.children || Facility.none
    @meta_title = "Book Fitness"
    @meta_desc  = "Gym, Gyrotonic, Pilates, Yoga and the Lap Pool at Bali Beach Country Club"
  end

  def spa_wellness
    @section    = club_life_root("Spa + Wellness")
    @children   = @section&.children || Facility.none
    @treatments = @children.any? ? Treatment.where(facility_id: @children.map(&:id)).order(:position) : Treatment.none
    @meta_title = "Book Spa & Wellness"
    @meta_desc  = "Spa, Recovery and Anti Aging treatments at Bali Beach Country Club"
  end

  def dining
    @restaurants = Restaurant.order(:position)
    @meta_title  = "Book Dining"
    @meta_desc   = "Reserve a table at any of the restaurants and bars at Bali Beach Country Club"
  end

  private

  # Every hub page closes with the shared blog strip.
  def set_articles
    @articles = Article.where(status: 1).first(3)
  end

  # The hub pages front the same Club Life sections the menu does, so they read
  # from the same records rather than repeating the copy.
  def club_life_root(en_name)
    Facility.club_life_roots.find { |section| section.en_name == en_name }
  end

  def set_banner
    @banner = BannerSection.where(name: "Booking").first&.banners&.first ||
              BannerSection.where(name: "Club Life").first&.banners&.first
  end
end
