module QuilleditorExtension

  extend ActiveSupport::Concern

  included do
    before_validation -> { check_description_empty }
  end

	protected

	def check_description_empty
		if self.has_attribute?(:short_description)
			self.short_description = "" if self.short_description == "<p><br></p>"
		end
		self.description = "" if self.description == "<p><br></p>"
	end

end
