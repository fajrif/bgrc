class MenuCategory < ApplicationRecord
	extend Mobility
	translates :name

	default_scope { order(position: :asc, id: :asc) }

	has_many :menus, dependent: :nullify

	validates_presence_of :name, :slug
	validates_uniqueness_of :slug

	before_validation :derive_slug, if: -> { slug.blank? }

	private

	# Admins fill in a name, not a slug; derive it from the English name so the
	# filter tabs get a stable key without asking for one.
	def derive_slug
		self.slug = Mobility.with_locale(:en) { name }.to_s.parameterize.presence
	end
end
