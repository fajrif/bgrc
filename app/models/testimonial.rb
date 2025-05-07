class Testimonial < ApplicationRecord
  validates_presence_of :name, :email, :comment
end
