class TeamMember < ApplicationRecord
	extend Mobility
  translates :role, :bio

	has_one_attached :photo, dependent: :purge

	validates :photo, content_type: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg'],
										size: { less_than: 50.megabytes, message: 'Image maximum 50MB' }
	validates_presence_of :name, :department

	default_scope { order(position: :asc, id: :asc) }

	DEPARTMENTS = %w[fnb sports specialists].freeze
	DEPARTMENT_LABELS = { "fnb" => "F&B" }.freeze

	def self.department_label(key)
		DEPARTMENT_LABELS[key] || key.to_s.titleize
	end

	def department_label
		self.class.department_label(department)
	end
end
