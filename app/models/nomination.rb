class Nomination < ActiveRecord::Base
  belongs_to :institution

  validates :reason, length: { in: 1..2300 }
  validates :institution, presence: true
  validates :name, presence: true
  validates :nominator, presence: true

  # Mostly the user's problem if email is incorrect, just checking
  # that something with an at sign is entered
  validates :nominator_email, presence: true,
    format: { with: /@/, message: 'må være en gyldig e-postadresse' }

  scope :ordered, -> { order(name: :asc) }
end
