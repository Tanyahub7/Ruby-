class Actor < ApplicationRecord
  belongs_to :movie, optional: true

  validates :name, presence: true
end
