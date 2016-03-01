class Institution < ActiveRecord::Base
  validates :abbreviation, uniqueness: true
end
