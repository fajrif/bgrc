module PublishedExtension

  extend ActiveSupport::Concern

  included do
		before_validation :check_published_date, on: :create
  end

	def check_published_date
		self.published_date = DateTime.now if self.published_date.blank?
	end

	def get_type
		self.class.to_s.downcase
	end

	def published?
		self.status == 1
	end

	def published_label
		self.published? ? "Published" : "Draft"
	end

	def published_date_label(use_time=true)
		_format = use_time ? '%d/%m/%Y %H:%M' : '%d/%m/%Y'
		self.try(:published_date).try(:strftime, _format)
	end

end
