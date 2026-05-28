class Movie < ApplicationRecord
  belongs_to :genre, optional: true
  has_many :actors, dependent: :destroy

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

  # Scopes по status
  scope :watched_movies,      -> { where(status: :watched) }
  scope :want_to_watch_movies, -> { where(status: :want_to_watch) }

  # Scope по рейтингу (поріг 8.0)
  scope :highly_rated, -> { where('rating >= ?', 8.0) }

  # Scope по даті — фільми з релізом у поточному році
  scope :released_this_year, -> {
    where(release_date: Date.current.beginning_of_year..Date.current.end_of_year)
  }
end
