class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # empty user means a guest

    # Users can read verified (published) nominations
    can :read, Reason, verified: true
    can :read, Nomination, reasons: { verified: true }
    can :vote, Nomination, reasons: { verified: true }
    can :create, Nomination

    # And read institutions
    can :read, Institution

    # But users (that is, admins)
    if user.persisted?
      # can do everything
      can :manage, :all
    end
  end
end
