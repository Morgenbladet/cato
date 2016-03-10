class NominationMailer < ApplicationMailer
  def nomination_verified(nomination)
    @nomination = nomination
    mail to: @nomination.nominator_email, subject: 'Din nominasjon er godkjent'
  end
end
