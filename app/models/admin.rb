class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable, :validatable

	scope :role_not_admin, -> { joins(:role).where("lower(roles.name) <> ?", "admin") }
	scope :role_only_investor, -> { joins(:role).where("lower(roles.name) = ?", "investor") }
	scope :role_only_media, -> { joins(:role).where("lower(roles.name) = ?", "media") }
	scope :role_only_partner, -> { joins(:role).where("lower(roles.name) = ?", "partner") }
	scope :role_only_developer, -> { joins(:role).where("lower(roles.name) = ?", "developer") }

  # Validations
  validates_presence_of :email, :full_name
	validates :email, email: true
  validates_uniqueness_of :email

	belongs_to :role

	def admin?
		check_role?(:admin)
	end

	def investor?
		check_role?(:investor)
	end

	def media?
		check_role?(:media)
	end

	def partner?
		check_role?(:partner)
	end

	def developer?
		check_role?(:developer)
	end

	protected

	def check_role?(role)
		self.role.name.downcase.to_sym == role
	end

end
