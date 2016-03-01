class Institution < ActiveRecord::Base
  has_many :nominations,
    dependent: :restrict_with_error,
    inverse_of: :institution

  validates :abbreviation, uniqueness: true

  scope :ordered, -> { order(priority: :desc, name: :asc) }
end
