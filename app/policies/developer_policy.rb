class DeveloperPolicy < ApplicationPolicy

  def index?
	  only_admin_developer
  end

  def create?
	  only_admin_developer
  end

  def show?
	  only_admin_developer
  end

  def update?
	  only_admin_developer
  end

  def destroy?
	  only_admin_developer
  end

	def edit_link_button?
		only_admin_developer
	end

	def update_link_button?
		only_admin_developer
	end

  def clear_link_button?
		only_admin_developer
	end

	def objectable_types?
		only_admin_developer
	end

	def delete_attachment?
		only_admin_developer
	end

	def delete_attachment_locale?
		only_admin_developer
	end

	def sort?
		only_admin_developer
	end

	private

	def only_admin_developer
		current_admin.admin? || current_admin.developer?
	end

end
