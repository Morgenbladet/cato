class Reason < ActiveRecord::Base
  belongs_to :nomination, inverse_of: :reasons, counter_cache: true

  validates :reason, length: { in: 1..2300 }
  validates :nominator, presence: true

  # Mostly the user's problem if email is incorrect, just checking
  # that something with an at sign is entered
  validates :nominator_email, presence: true,
    format: { with: /@/, message: 'må være en gyldig e-postadresse' }


  scope :verified, ->   { where(verified: true)  }
  scope :unverified, -> { where(verified: false) }
end
