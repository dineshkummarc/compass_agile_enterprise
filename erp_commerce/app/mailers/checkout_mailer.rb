class CheckoutMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def email_confirmation(to_email, order, payment)
    @order = order
    @payment = payment
    mail(:to => to_email, :subject => 'Your Confirmation')
  end
end
