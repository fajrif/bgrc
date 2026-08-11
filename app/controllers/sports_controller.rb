class SportsController < ApplicationController

  def show
		@sport = Sport.friendly.find(params[:id])

		# Sports are presented through Club Life when a section is linked to them.
		# Sports added later without a section keep the original page.
		section = Facility.find_by(sport_id: @sport.id, club_life: true) ||
							Facility.where(sport_id: @sport.id).where.not(parent_id: nil).first
		return redirect_to helpers.club_life_page_path(section), status: :moved_permanently if section&.in_club_life?

		@banner = BannerSection.where(name: @sport.name).first&.banners&.first
		@meta_title = @sport.name
		@meta_desc = @sport.short_description
		@group_classes = GroupClass.available.where(sport_id: @sport.id).includes(:group_class_packs)
  end

end
