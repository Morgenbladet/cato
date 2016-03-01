class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # empty user means a guest

    # Users can create nominations
    can :create, Nomination

    # And read verified (published) nominations
    can :read, Nomination, verified: true

    # And read institutions
    can :read, Institution

    # But users (that is, admins)
    if user.persisted?
      # can do everything
      can :manage, :all
    end
  end
end
