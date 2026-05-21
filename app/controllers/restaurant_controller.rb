class RestaurantController < ApplicationController
  def index
    @facility = Facility.find_by("name @> ?", { en: "Restaurant" }.to_json)
    @meta_title = t("menu.restaurant")
    @meta_desc = @facility&.short_description
  end
end
