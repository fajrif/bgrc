class HomeController < ApplicationController

  def index
		# get public home — data-backed sections only; other sections are static.
    @testimonials = Testimonial.first(6)
    @articles = Article.where(status: 1).first(3)
    @faqs = Question.where(section: "general").limit(6)
  end

  def about
		# get public about
    @banner = BannerSection.where(name: "About").first.banners.first
    @sports = Sport.first(4)
    @testimonials = Testimonial.first(6)
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
