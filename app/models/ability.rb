class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # empty user means a guest

    alias_action :random, to: :read
    alias_action :merge, to: :manage

    # Users can read verified (published) nominations
    can :read, Reason, verified: true
    can :read, Nomination, reasons: { verified: true }
    can :vote, Nomination, reasons: { verified: true }

    # And read institutions
    can :read, Institution

    # But users (that is, admins)
    if user.persisted?
      # can do everything
      can :manage, :all
    end
  end
end
