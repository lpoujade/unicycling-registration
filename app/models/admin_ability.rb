class AdminAbility
  include CanCan::Ability

  def initialize(user)
    if user.nil?
    else
      if user.has_role? :admin or user.has_role? :super_admin
        can :manage, Payment
        if user.has_role? :admin
          cannot :create, Payment
        end
        can :onsite_pay_new, Payment
        can :onsite_pay_confirm, Payment
        can :onsite_pay_create, Payment
        can :adjust_payment_choose, Payment
        can :refund_choose, Payment
        can :refund_create, Payment
        can :manage, Registrant
        can :email, Registrant
      end

      if user.has_role? :super_admin
        can :manage, Payment
        can :manage, :export

        # the only role that can assign other roles:
        can :manage, User

        can :manage, StandardSkillEntry
        can :manage, StandardSkillRoutine
      end
    end
  end
end
