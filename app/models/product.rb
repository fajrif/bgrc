#class Product < ApplicationRecord
	#extend FriendlyId

  #friendly_id :name, use: :slugged

	## default_scope { order(created_at: :desc) }

	#has_many :purchases, as: :productable

	#has_many_attached :images

	#validates_presence_of :name, :price
	#validates_uniqueness_of :name

	#def name_label
		#self.name
	#end

	#def is_available?
		#self.quantity > 0
	#end

	#def price_label
		#ActionController::Base.helpers.number_to_currency(self.price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	#end

	#def should_generate_new_friendly_id?
    #name_changed?
  #end
#end
