class NominationMailer < ApplicationMailer
  def nomination_verified(nomination)
    @nomination = nomination
    mail to: @nomination.nominator_email, subject: 'Din nominasjon er godkjent'
  end

  def notify_new(nomination)
    @nomination = nomination
    mail to: User.pluck(:email), subject: "Ny nominasjon: #{nomination.name}"
  end
end
