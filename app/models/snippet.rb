class Snippet < ApplicationRecord
  has_rich_text :content

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true

  def self.find_by_key(key)
    find_by(key: key)
  end
end
