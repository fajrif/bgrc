class AdminPolicy < ApplicationPolicy

  def index?
	  only_admin
  end

  def create?
	  only_admin
  end

  def show?
	  only_admin
  end

  def update?
	  only_admin
  end

  def destroy?
	  only_admin
  end

	private

	def only_admin
		current_admin.admin?
	end

end
