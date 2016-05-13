class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # empty user means a guest

    alias_action :merge, to: :update
    alias_action :full_report, to: :read
    alias_action :shortlist, to: :read
    alias_action :shortlist_report, to: :read

    can :read, Institution

    if user.persisted? # Logged in
      # Regular users can read
      can :read, :all

      if user.admin?
        can :manage, :all
      end
    end
  end
end
