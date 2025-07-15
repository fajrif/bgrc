class GroupClass < ApplicationRecord

	default_scope { order(id: :asc) }

	validates_presence_of :name, :price
	validates_uniqueness_of :name

  has_many :bookings

	def name_label
    if self.has_additional_pax?
      "#{self.name} (#{self.duration_label})"
    else
      self.name
    end
	end

	def name_with_pax(pax)
    if self.has_additional_pax?
      "#{self.name} (#{pax} Pax)"
    else
      "#{self.name}"
    end
	end

	def duration_label
    "#{self.min_duration} hour".titleize.pluralize(self.min_duration)
	end

	def status_label
		self.status == 1 ? "Available" : "Unavailable"
	end

	def has_additional_pax?
		self.price_pax > 0
	end

	def check_price(pax=nil, currency_label=true)
    _price = self.price
    unless pax.nil?
      if self.has_additional_pax?
        unless self.min_pax == pax.to_i
          if self.id == 4
            _price = self.price + (self.price_pax * pax.to_i)
          else
            _price = self.price_pax * pax.to_i
          end
        end
      end
    end
    currency_label ? label_price(_price) : _price
	end

	def price_label
		label_price(self.price)
	end

	def price_pax_label
		label_price(self.price_pax) + " / Pax"
	end

  protected

  def label_price(_price)
		ActionController::Base.helpers.number_to_currency(_price, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
  end
end
