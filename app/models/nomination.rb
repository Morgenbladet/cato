class Nomination < ActiveRecord::Base
  belongs_to :institution

  validates :reason, length: { in: 1..2300 }
  validates :institution, presence: true
  validates :name, presence: true
  validates :nominator, presence: true
  validates :year_of_birth, numericality: { only_integer: true, greater_than: 1799, less_than: 2000, allow_blank: true }

  # Mostly the user's problem if email is incorrect, just checking
  # that something with an at sign is entered
  validates :nominator_email, presence: true,
    format: { with: /@/, message: 'må være en gyldig e-postadresse' }

  scope :ordered, -> { order(name: :asc) }
  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  around_update :send_mail_to_nominator

  after_create :notify_admins

  scope :sorted_by, lambda {|sort_key|
    direction = (sort_key =~ /desc$/) ? 'desc' : 'asc'
    case sort_key.to_s
    when /^name/
      order(name: direction)
    when /^institution/
      joins(:institution).order("institutions.name #{direction}")
    when /^votes/
      order(votes: direction)
    else
      raise ArgumentError, "Invalid sort option '#{sort_key}'"
    end
  }

  def age
    return nil unless self.year_of_birth.is_a? Integer
    Date.today.year - self.year_of_birth
  end

  def rank
    index = Nomination.order(votes: :desc).pluck(:votes).find_index do |v|
      self.votes >= v
    end

    if index.nil?
      # Database changed since record loaded, just return last place
      Nomination.count
    else
      index + 1
    end
  end

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
