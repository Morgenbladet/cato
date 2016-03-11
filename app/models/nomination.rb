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

  around_update :send_mail_to_nominator

  after_create :notify_admins

  private

  def send_mail_to_nominator
    verified_changed = self.verified_changed?

    yield

    if verified && verified_changed
      NominationMailer.nomination_verified(self).deliver_now
    end
  end

  def notify_admins
    NominationMailer.notify_new(self).deliver_now
  end
end
