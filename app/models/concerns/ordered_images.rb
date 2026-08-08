# Active Storage hands attachments back in insertion order and offers no way to
# change it, so gallery photos carry a position of their own. Include this in a
# model that already declares `has_many_attached :images` and read the gallery
# through `ordered_images` rather than the bare association.
module OrderedImages
	extend ActiveSupport::Concern

	def ordered_images
		images_attachments.includes(:blob).order(position: :asc, id: :asc)
	end

	# Everything uploaded before ordering existed sits at position 0. Hand out
	# sequential numbers first so neighbours are always distinct to swap.
	def normalize_image_positions!
		ordered_images.each_with_index do |attachment, index|
			attachment.update_column(:position, index + 1) unless attachment.position == index + 1
		end
	end

	# Swaps a gallery photo with the neighbour `offset` places away.
	# Returns false when the photo is already at that end of the gallery.
	def move_image!(attachment_id, offset)
		normalize_image_positions!
		list  = ordered_images.to_a
		index = list.index { |attachment| attachment.id == attachment_id.to_i }
		return false if index.nil?

		target = index + offset
		return false if target.negative? || target >= list.size

		list[index].update_column(:position, target + 1)
		list[target].update_column(:position, index + 1)
		true
	end
end
