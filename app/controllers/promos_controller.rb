class PromosController < ApplicationController

  def index
    criteria = Promo.all
		@promos = criteria.page(params[:page]).per(6)

		@meta_title = "Our Promos"
		@meta_desc = "promos"
  end

  def show
		@promo = Promo.friendly.find(params[:id])
		@meta_title = @promo.name
		@meta_desc = @promo.short_description
  end

end
