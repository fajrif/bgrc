class SportsController < ApplicationController

  def show
		@sport = Sport.friendly.find(params[:id])
		@meta_title = @sport.name
		@meta_desc = @sport.short_description
  end

end
