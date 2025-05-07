class Admins::DashboardController < Admins::BaseController

  def index
		@total_articles = Article.count
		@total_facilities = Facility.count
		@total_events = Event.count
		@total_promos = Promo.count
  end

end
