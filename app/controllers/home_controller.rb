class HomeController < ApplicationController

  def index
		# get public home
    @banner = BannerSection.where(name: "Home").first.banners.first
    @testimonials = Testimonial.first(6)
    @facilities = Facility.first(3)
    @sports = Sport.first(4)
    @event = Event.featured_events.first
    @packages = Package.first(3)
    @promos = Promo.first(3)
    @articles = Article.first(3)
    @faqs = Question.where("section = ?", "general").limit(5)
  end

  def about
		# get public about
    @banner = BannerSection.where(name: "About").first.banners.first
  end

  def disclaimer
		# get public disclaimer
  end

  def privacy
		# get public privacy
  end

  def faq
		# get public faq
    @faqs = Question.all
  end
end
