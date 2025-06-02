class FacilitiesController < ApplicationController

  def index
    criteria = Facility.all
		@facilities = criteria.page(params[:page]).per(6)

		@meta_title = "Our Facilities"
		@meta_desc = "Facilities"
  end

  def show
		@facility = Facility.friendly.find(params[:id])
		@meta_title = @facility.name
		@meta_desc = @facility.short_description
  end

end
