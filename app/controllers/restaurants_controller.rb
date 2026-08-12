class RestaurantsController < ApplicationController
  # Three venues were shortened to the names the sitemap uses, and friendly_id
  # regenerated their slugs to match. Their old addresses still resolve.
  RENAMED_SLUGS = {
    "kazumi-azayaka"    => "kasumi",
    "pit-lane-sportsbar" => "pit-lane",
    "portobello"        => "porto"
  }.freeze

  # friendly_id drops the ampersand entirely, giving "grab-go", so the seed sets
  # this slug explicitly and the ordering page keys off it.
  GRAB_AND_GO_SLUG = "grab-and-go".freeze

  def index
    @banner      = BannerSection.where(name: "Dining").first&.banners&.first
    @restaurants = Restaurant.order(:position)
    @articles    = Article.where(status: 1).first(3)
    @meta_title  = "Dining"
  end

  def show
    if (renamed = RENAMED_SLUGS[params[:id]])
      return redirect_to dining_restaurant_path(renamed), status: :moved_permanently
    end

    @restaurant  = Restaurant.friendly.find(params[:id])
    @restaurants = Restaurant.order(:position)
    @others      = @restaurants.where.not(id: @restaurant.id).limit(3)
    @articles    = Article.where(status: 1).first(3)
    @meta_title  = @restaurant.name
    @meta_desc   = @restaurant.short_description

    # Grab & Go is a counter, not a dining room: it gets an ordering page instead
    # of the venue template. The menu is pooled from every restaurant, so anything
    # an admin has marked orderable shows up here regardless of which kitchen it
    # belongs to.
    render :grab_and_go if grab_and_go_menu!
  end

  private

  def grab_and_go_menu!
    return false unless @restaurant.slug == GRAB_AND_GO_SLUG

    # Everything on sale, including what has sold out — an item nobody can order
    # today still tells a guest it exists, so it renders greyed rather than hidden.
    @menus = Menu.orderable
                 .includes(:menu_category, :restaurant, image_attachment: :blob)
                 .order(:position, :id)
                 .sort_by { |menu| [menu.menu_category&.position || 0, menu.position, menu.id] }
    @menu_categories = MenuCategory.where(id: @menus.map(&:menu_category_id).compact.uniq)
    true
  end
end
