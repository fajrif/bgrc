class Provider < ApplicationRecord

  belongs_to :user

  validates_format_of :provider, :with => /twitter|facebook|github|linkedin|google_oauth2/, :on => :create
  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid

end
