require 'mailgun'

class MailgunHelper
  def initialize(key, domain)
    Mailgun.configure do |config|
      config.api_key = key
      config.domain  = domain
    end
    @mailgun = Mailgun()
  end

  def send_email(address, subject, message)
    parameters = {
      :to => address,
      :subject => subject,
      :text => message,
      :from => "postmaster@sandboxdf010bb13e0c496da784c83c9aa6f1f2.mailgun.org"
    }
    @mailgun.messages.send_email(parameters)
  end
end