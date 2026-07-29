class ClubLifeController < ApplicationController
  before_action :set_banner

  def index
    # get public club life — the five top-level sections, in display order
    @sections = Facility.club_life_roots.includes(:children, image_attachment: :blob)
    @articles = Article.where(status: 1).first(3)
  end

  def show
    @section = Facility.friendly.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @section.in_club_life?

    @root     = @section.club_life_root
    @children = @section.children
    @gallery  = @section.gallery_images

    # Linked sports carry the real class programme; unlinked sections show none.
    @group_classes = @section.sport_id.present? ? GroupClass.available.where(sport_id: @section.sport_id) : GroupClass.none
    @specialists   = @root&.en_name == "Spa + Wellness" ? TeamMember.where(department: "specialists") : TeamMember.none
    @show_mits     = @root&.en_name == "Racquet Sports"

    @meta_title = @section.name
    @meta_desc  = @section.short_description
    @articles   = Article.where(status: 1).first(3)
  end

  private

  def set_banner
    @banner = BannerSection.where(name: "Club Life").first&.banners&.first
  end
end
