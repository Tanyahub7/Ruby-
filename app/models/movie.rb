class Movie < ApplicationRecord
  belongs_to :genre, optional: true

  enum :status, {
    want_to_watch: 'want_to_watch',
    watching:      'watching',
    watched:       'watched'
  }

  validates :title, presence: true
  validates :rating, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 10
  }, allow_nil: true
end
