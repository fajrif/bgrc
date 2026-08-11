# Mobility stores a slug per locale, so "/id/events/weddings" (an English slug
# under the Indonesian prefix) finds nothing on the first pass even though the
# record exists. This looks the slug up in the active locale first, then in the
# others; callers then redirect to the canonical address for the locale the
# visitor is actually browsing in, so each page still answers at one address.
module LocalizedLookup
	extend ActiveSupport::Concern

	private

	def find_by_localized_slug(model, slug)
		found = friendly_find(model, slug)
		return found if found

		I18n.available_locales.each do |locale|
			next if locale == Mobility.locale
			found = Mobility.with_locale(locale) { friendly_find(model, slug) }
			return found if found
		end
		nil
	end

	def friendly_find(model, slug)
		model.friendly.find(slug)
	rescue ActiveRecord::RecordNotFound
		nil
	end
end
