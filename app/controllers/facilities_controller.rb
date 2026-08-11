class FacilitiesController < ApplicationController

  # Facilities are now presented through Club Life; the old flat list is gone.
  def index
    redirect_to club_life_path, status: :moved_permanently
  end

  def show
		@facility = Facility.friendly.find(params[:id])
		return redirect_to helpers.club_life_page_path(@facility), status: :moved_permanently if @facility.in_club_life?

		@meta_title = @facility.name
		@meta_desc = @facility.short_description
  end

end
