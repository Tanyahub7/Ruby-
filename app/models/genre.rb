class Genre < ApplicationRecord
  has_many :movies, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
