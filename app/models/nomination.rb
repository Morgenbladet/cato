class Nomination < ActiveRecord::Base
  belongs_to :institution, counter_cache: true
  has_many :reasons, inverse_of: :nomination, dependent: :destroy

  accepts_nested_attributes_for :reasons

  validates :institution, presence: true
  validates :name, presence: true
  validates :year_of_birth, numericality: { only_integer: true, greater_than: 1799, less_than: 2000, allow_blank: true }

  scope :verified_reasons, -> { reasons.where(verified: true) }

  scope :ordered, -> { order(name: :asc) }
  scope :verified, -> { joins(:reasons).where(reasons: { verified: true }).uniq }

  scope :ten_random, -> { order('RANDOM()').limit(10) }

  scope :search, ->(txt) { where('LOWER(name) LIKE ?', "%#{txt.downcase}%") }

  scope :sorted_by, lambda {|sort_key|
    direction = (sort_key =~ /desc$/) ? 'desc' : 'asc'
    case sort_key.to_s
    when /^name/
      order(name: direction)
    when /^institution/
      joins(:institution).order("institutions.name #{direction}")
    when /^votes/
      order(votes: direction)
    when /^reasons/
      order("reasons_count #{direction}")
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

  def verified?
    reasons.where(verified: true).any?
  end

  def eat!(target)
    target.reasons.each do |r|
      r.nomination = self
      r.save!
    end

    self.votes += target.votes

    self.gender = target.gender if gender.blank?
    self.year_of_birth = target.year_of_birth if year_of_birth.blank?
    self.branch = target.branch if branch.blank?

    save!

    target.reload.destroy
  end
end
