class BannerSection < ApplicationRecord

	validates_presence_of :name
	validates_uniqueness_of :name

	has_many :banners
	has_many :pages

	def name_size_label
		"#{self.name} (#{self.banners.size})"
	end

	def name_id_label
		"#{self.name} [ID:#{self.id.to_s}]"
	end

	def style_label
		self.is_dark_theme? ? "dark-theme" : "light-theme"
	end

	def is_dark_theme?
		self.style == 0
	end

	def is_large?
		self.size == 0
	end

	def is_medium?
		self.size == 1
	end

	def is_small?
		self.size == 2
	end

	def size_label
		case self.size
		when 1
			"medium"
		when 2
			"small"
		else
			"large"
		end
	end
end
