class UserMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def activation_needed_email(user)
    @user = user
    @url  = "#{get_domain(user.instance_attributes[:domain])}/users/activate/#{user.activation_token}"
    @url << "?login_url=#{@user.instance_attributes[:login_url]}" unless @user.instance_attributes[:login_url].nil?
    mail(:to => user.email, :subject => "An account has been created and needs activation")
  end

  def reset_password_email(user)
    @user = user
    @url  = "#{get_domain(user.instance_attributes[:domain])}#{@user.instance_attributes[:login_url]}"
    mail(:to => user.email, :subject => "Your password has been reset")
  end

  def get_domain(domain)
    domain = domain || ErpTechSvcs::Config.installation_domain
    domain = "http://#{domain}" if domain.index('http').nil?
    domain
  end
end